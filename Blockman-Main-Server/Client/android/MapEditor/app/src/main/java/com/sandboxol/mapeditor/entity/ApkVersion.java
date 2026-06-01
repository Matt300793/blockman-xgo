package com.sandboxol.mapeditor.entity;

/**
 * Created by Arthur on 2015/8/2.
 */
public class ApkVersion {
    private static final String BETA_PREFIX = "b";

    private int major = 0;
    private int minor = 0;
    private int patch = 0;
    private int test = 0;
    private String beta = "";
    private int len;

    public ApkVersion() {

    }

    public ApkVersion(Integer major, Integer minor, Integer patch, String beta) {
        super();
        this.major = major;
        this.minor = minor;
        this.patch = patch;
        this.beta = beta;
    }

    public static ApkVersion fromVersionString(String version) {
        if (version == null || version.length() == 0) {
            return new ApkVersion();
        }

        ApkVersion v = new ApkVersion();
        String[] ss = version.split("[.]");

        if (ss.length > 0) {
            v.setMajor(parse(ss[0]));
        }
        if (ss.length > 1) {
            v.setMinor(parse(ss[1]));
        }
        if (ss.length > 2) {
            v.setPatch(parse(ss[2]));
        }
        if (ss.length > 3) {
            v.setBeta(parseString(ss[3]));
            v.setTest(parse(ss[3]));
        }
        v.setLen(ss.length);
        return v;
    }

    public static String removeForthPart(String version) {
        ApkVersion apkVersion = fromVersionString(version);
        if (apkVersion.getTest() != 0)
            return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch() + "." + apkVersion.getTest();
        return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch();
    }

    public static String forthPart(String version) {
        ApkVersion apkVersion = fromVersionString(version);
        return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch() + "." + apkVersion.getTest();
    }

    public static boolean VersionMatch(String version, String current) {
        ApkVersion apkVersion = fromVersionString(version);
        ApkVersion localVersion = fromVersionString(current);
        return apkVersion.getMajor() == localVersion.getMajor() && apkVersion.getMinor() == localVersion.getMinor();
    }

    public static String getTwoVersionNumber(String version) {
        ApkVersion apkVersion = fromVersionString(version);
        return apkVersion.getMajor() + "." + apkVersion.getMinor();
    }

    public static String getThreeVersionNumber(String version) {
        ApkVersion apkVersion = fromVersionString(version);
        return apkVersion.getMajor() + "." + apkVersion.getMinor() + "." + apkVersion.getPatch();
    }


    private static Integer parse(String s) {
        Integer i = 0;
        try {
            if (s.startsWith(BETA_PREFIX)) {
                s = s.substring(1);
            }

            i = Integer.parseInt(s);
        } catch (Exception e) {
        }
        return i;
    }

    private static String parseString(String s) {
        String i = "";
        try {
            if (s.startsWith(BETA_PREFIX)) {
                s = s.substring(1);
            }

            i = s;
        } catch (Exception e) {
        }

        return i;
    }

    public int getMajor() {
        return major;
    }

    public void setMajor(int major) {
        this.major = major;
    }

    public int getMinor() {
        return minor;
    }

    public void setMinor(int minor) {
        this.minor = minor;
    }

    public int getPatch() {
        return patch;
    }

    public void setPatch(int patch) {
        this.patch = patch;
    }

    public int getTest() {
        return test;
    }

    public void setTest(int test) {
        this.test = test;
    }

    public String getBeta() {
        return beta;
    }

    public void setBeta(String beta) {
        this.beta = beta;
    }

    public int getLen() {
        return len;
    }

    public void setLen(int len) {
        this.len = len;
    }
}
