package main

import (
	"bufio"
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha1"
	"encoding/base64"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

type UserImage struct {
	UserID   string
	ImageURL string
}

type ValidResponse struct {
	Error   string      `json:"error"`
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Result  ValidResult `json:"result"`
}

type ValidResult struct {
	Suggestion string `json:"suggestion"`
}

var (
	url        = "http://ai.qiniuapi.com/v3/image/censor"
	access_key = "pHC4IE2wGOLBsN5p7w50GZVtBf1mtMocPw9_dEbK"
	secret_key = "bYDaT71OQPJiF-ZzyiZpLCzmzXH_rxjQNxvwIodx"

	cred = New(access_key, secret_key)

	resultFile, _ = os.OpenFile("result.csv", os.O_CREATE|os.O_RDWR|os.O_APPEND, os.ModeAppend|os.ModePerm)
	wg            sync.WaitGroup

	userIDChan   = make(chan UserImage, 1500)
	ctx, cancelF = context.WithCancel(context.Background())

	totalCount int64 = 0
)

func main() {
	var startUserId = readLastLine()
	if len(os.Args) > 1 {
		startUserId = os.Args[1]
	}

	fmt.Printf("start from user id: %s\n", startUserId)

	n := time.Now()

	go readUsers("validate_user_before.txt", startUserId)

	for i := 0; i < 400; i++ {
		wg.Add(1)
		go func(i int) {
			doCheckImage(i)

			wg.Done()
		}(i)
	}

	wg.Wait()
	resultFile.Close()

	fmt.Printf("total process number: %v\n", totalCount)
	fmt.Printf("time: %v\n", time.Since(n).Minutes())
}

func readLastLine() string {
	file, err := os.Open("result.csv")
	if err != nil {
		fmt.Println("Read Last Line Error", err)
		return ""
	}
	defer file.Close()

	scaner := bufio.NewScanner(file)
	scaner.Split(bufio.ScanLines)
	var l string
	for scaner.Scan() {
		l = scaner.Text()
	}

	if len(l) > 0 {
		_ref := strings.Split(l, ",")
		if len(_ref) > 0 {
			return _ref[0]
		}
	}

	return ""
}

func doCheckImage(sno int) {
	count := 0
loop:
	for {
		select {
		case ui, isClose := <-userIDChan:
			if !isClose {
				break loop
			}

			if ok, suggestion := validImage(ui.ImageURL); !ok {
				writeResult(resultFile, ui, suggestion)
			}

			// fmt.Printf("%d %v\n", atomic.LoadInt64(&totalCount), ui)
			atomic.AddInt64(&totalCount, 1)
			wg.Done()
			count++
		}
	}
	fmt.Printf("doCheckImage finished %v, process count %d\n", sno, count)
}

func readUsers(fn string, startUserId string) {
	file, err := os.Open(fn)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer file.Close()
	reader := csv.NewReader(file)
	lines := 0

	start := true
	if len(startUserId) > 0 {
		start = false
	}

	for {
		record, err := reader.Read()
		if err == io.EOF {
			fmt.Println("----------------------------read csv finished")
			close(userIDChan)
			break
		} else if err != nil {
			fmt.Println("Read Error:", err)
			continue
		}

		lines++
		if lines%100000 == 0 {
			fmt.Printf("%v current lines: %d\n", time.Now(), lines)
		}

		if len(startUserId) > 0 && startUserId == record[0] {
			start = true
		}

		if !start {
			continue
		}

		if len(record) > 1 {
			userImage := UserImage{UserID: record[0], ImageURL: record[1]}
			userIDChan <- userImage

			wg.Add(1)
		}
	}

	fmt.Printf("%s total lines %d\n", fn, lines)
}

func writeResult(f *os.File, ui UserImage, suggestion string) {
	f.Write([]byte(ui.UserID + "," + ui.ImageURL + "," + suggestion + "\n"))
}

func validImage(imgURL string) (bool, string) {
	defer func() {
		if err := recover(); err != nil {
			const size = 16 << 10
			buf := make([]byte, size)
			buf = buf[:runtime.Stack(buf, false)]
			fmt.Printf("validImage panic " + string(buf))
		}
	}()

	client := &http.Client{}

	body := map[string]interface{}{
		"data": map[string]string{
			"uri": imgURL,
		},
		"params": map[string][]string{
			"scenes": []string{"pulp"},
		},
	}
	b, err := json.Marshal(body)
	if err != nil {
		panic(err)
	}

	buf := bytes.NewBuffer(b)
	defer buf.Reset()

	request, err := http.NewRequest("POST", url, buf)
	if err != nil {
		panic(err)
	}

	request.Header.Set("Content-Type", "application/json")

	err = cred.AddToken(TokenQiniu, request)
	if err != nil {
		panic(err)
	}

	response, err := client.Do(request)
	if err != nil {
		fmt.Printf("Do request error %v\n", err)
	}
	defer response.Body.Close()

	b, err = ioutil.ReadAll(response.Body)
	if err != nil {
		fmt.Printf("read response body error %v\n", err)
	}

	vr := &ValidResponse{}
	json.Unmarshal(b, vr)

	// status := response.StatusCode
	// fmt.Println(status)

	if vr.Code == 200 && vr.Result.Suggestion == "pass" {
		return true, vr.Result.Suggestion
	}

	// fmt.Printf("%v %s\n", vr, string(b))
	msg := vr.Result.Suggestion
	if len(msg) == 0 {
		msg = vr.Error

		if len(msg) == 0 {
			msg = vr.Message
		}
	}
	return false, msg
}

// 七牛签名算法的类型：
// QBoxToken, QiniuToken, BearToken, QiniuMacToken
type TokenType int

const (
	TokenQiniu TokenType = iota
	TokenQBox
)

//  七牛鉴权类，用于生成Qbox, Qiniu, Upload签名
// AK/SK可以从 https://portal.qiniu.com/user/key 获取。
type Credentials struct {
	AccessKey string
	SecretKey []byte
}

// 构建一个Credentials对象
func New(accessKey, secretKey string) *Credentials {
	return &Credentials{accessKey, []byte(secretKey)}
}

// Sign 对数据进行签名，一般用于私有空间下载用途
func (ath *Credentials) Sign(data []byte) (token string) {
	h := hmac.New(sha1.New, ath.SecretKey)
	h.Write(data)

	sign := base64.URLEncoding.EncodeToString(h.Sum(nil))
	return fmt.Sprintf("%s:%s", ath.AccessKey, sign)
}

// SignToken 根据t的类型对请求进行签名，并把token加入req中
func (ath *Credentials) AddToken(t TokenType, req *http.Request) error {
	switch t {
	case TokenQiniu:
		token, sErr := ath.SignRequestV2(req)
		if sErr != nil {
			return sErr
		}
		req.Header.Add("Authorization", "Qiniu "+token)
	default:
		token, err := ath.SignRequest(req)
		if err != nil {
			return err
		}
		req.Header.Add("Authorization", "QBox "+token)
	}
	return nil
}

// SignWithData 对数据进行签名，一般用于上传凭证的生成用途
func (ath *Credentials) SignWithData(b []byte) (token string) {
	encodedData := base64.URLEncoding.EncodeToString(b)
	sign := ath.Sign([]byte(encodedData))
	return fmt.Sprintf("%s:%s", sign, encodedData)
}

func collectData(req *http.Request) (data []byte, err error) {
	u := req.URL
	s := u.Path
	if u.RawQuery != "" {
		s += "?"
		s += u.RawQuery
	}
	s += "\n"

	data = []byte(s)
	if incBody(req) {
		s2, rErr := BytesFromRequest(req)
		if rErr != nil {
			err = rErr
			return
		}
		req.Body = ioutil.NopCloser(bytes.NewReader(s2))
		data = append(data, s2...)
	}
	return
}

func collectDataV2(req *http.Request) (data []byte, err error) {
	u := req.URL

	//write method path?query
	s := fmt.Sprintf("%s %s", req.Method, u.Path)
	if u.RawQuery != "" {
		s += "?"
		s += u.RawQuery
	}

	//write host and post
	s += "\nHost: "
	s += req.Host

	//write content type
	contentType := req.Header.Get("Content-Type")
	if contentType != "" {
		s += "\n"
		s += fmt.Sprintf("Content-Type: %s", contentType)
	}
	s += "\n\n"

	data = []byte(s)
	//write body
	if incBodyV2(req) {
		s2, rErr := BytesFromRequest(req)
		if rErr != nil {
			err = rErr
			return
		}
		req.Body = ioutil.NopCloser(bytes.NewReader(s2))
		data = append(data, s2...)
	}
	return
}

// BytesFromRequest 读取http.Request.Body的内容到slice中
func BytesFromRequest(r *http.Request) (b []byte, err error) {
	if r.ContentLength == 0 {
		return
	}
	if r.ContentLength > 0 {
		b = make([]byte, int(r.ContentLength))
		_, err = io.ReadFull(r.Body, b)
		return
	}
	return ioutil.ReadAll(r.Body)
}

// SignRequest 对数据进行签名，一般用于管理凭证的生成
func (ath *Credentials) SignRequest(req *http.Request) (token string, err error) {
	data, err := collectData(req)
	if err != nil {
		return
	}
	token = ath.Sign(data)
	return
}

// SignRequestV2 对数据进行签名，一般用于高级管理凭证的生成
func (ath *Credentials) SignRequestV2(req *http.Request) (token string, err error) {

	data, err := collectDataV2(req)
	if err != nil {
		return
	}
	token = ath.Sign(data)
	return
}

// 管理凭证生成时，是否同时对request body进行签名
func incBody(req *http.Request) bool {
	return req.Body != nil && req.Header.Get("Content-Type") == "application/x-www-form-urlencoded"
}

func incBodyV2(req *http.Request) bool {
	contentType := req.Header.Get("Content-Type")
	return req.Body != nil && (contentType == "application/x-www-form-urlencoded" || contentType == "application/json")
}

// VerifyCallback 验证上传回调请求是否来自七牛
func (ath *Credentials) VerifyCallback(req *http.Request) (bool, error) {
	auth := req.Header.Get("Authorization")
	if auth == "" {
		return false, nil
	}

	token, err := ath.SignRequest(req)
	if err != nil {
		return false, err
	}

	return auth == "QBox "+token, nil
}
