//
//  DecorationContentView.swift
//  BlockyModes
//
//  Created by KiBen on 2018/1/4.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

protocol DecorationsViewDelegate: class {
    
    func decorationsView(_ decorationsView: DecorationsView, sizeForItemInPage page: Int, atIndex index: Int) -> CGSize
    func decorationsView(_ decorationsView: DecorationsView, didSelectItemInPage page: Int, atIndex index: Int)
    func decorationsView(_ decorationsView: DecorationsView, didDeselectItemInPage page: Int, atIndex index: Int)
    func decorationsView(_ decorationsView: DecorationsView, didBeginRefeshingInPage page: Int)
    func decorationsView(_ decorationsView: DecorationsView, didChangeTo page: Int)
    func decorationsViewWillBeginDecelerating(_ decorationsView: DecorationsView)
    func decorationsViewDidEndDecelerating(_ decorationsView: DecorationsView)
    func decorationsViewWillBeginDragging(_ decorationsView: DecorationsView)
    func decorationsViewDidEndDragging(_ decorationsView: DecorationsView)
}

extension DecorationsViewDelegate {
    func decorationsView(_ decorationsView: DecorationsView, sizeForItemInPage page: Int, atIndex index: Int) -> CGSize { return CGSize(width: 40, height: 40) }
    func decorationsView(_ decorationsView: DecorationsView, didSelectItemInPage page: Int, atIndex index: Int) { }
    func decorationsView(_ decorationsView: DecorationsView, didDeselectItemInPage page: Int, atIndex index: Int) { }
    func decorationsView(_ decorationsView: DecorationsView, didBeginRefeshingInPage page: Int) { }
    func decorationsView(_ decorationsView: DecorationsView, didChangeTo page: Int) { }
    func decorationsViewWillBeginDecelerating(_ decorationsView: DecorationsView) { }
    func decorationsViewDidEndDecelerating(_ decorationsView: DecorationsView) { }
    func decorationsViewWillBeginDragging(_ decorationsView: DecorationsView) { }
    func decorationsViewDidEndDragging(_ decorationsView: DecorationsView) { }
}

protocol DecorationsViewDataSource: class {
    
    func numberOfPages(in decorationsView: DecorationsView) -> Int
    func decorationsView(_ decorationsView: DecorationsView, numberOfItemsInPage page: Int) -> Int
    func decorationsView(_ decorationsView: DecorationsView, reusableCompomentInPage page: Int, atIndex index: Int) -> DecorationReusableView.Type
    func decorationsView(_ decorationsView: DecorationsView, contentForItemInPage page: Int, atIndex index: Int) -> Any?
    func decorationsView(_ decorationsView: DecorationsView, allowsRefreshingForPage page: Int) -> Bool
}

extension DecorationsViewDataSource {
    func decorationsView(_ decorationsView: DecorationsView, allowsRefreshingForPage page: Int) -> Bool { return false }
}

class DecorationsView: UIView {
    
    public weak var delegate: DecorationsViewDelegate?
    public weak var dataSource: DecorationsViewDataSource? {
        didSet {
            updatePageViews()
        }
    }
    
    public var currentPage: Int = 0
    
    fileprivate var refreshingPage = 0
    fileprivate weak var scrollView: UIScrollView!
    fileprivate var collectionViews: [DecorationCollectionView] = []
    fileprivate var selectedIndexPathsDict: [Int : [IndexPath]] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = UIScrollView().addTo(superView: self).configure { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
            }.layout { (make) in
                make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func triggleRefreshing(inPage page: Int) {
        collectionViews[page].beginRefreshing()
    }
    
    public func endRefreshing(inPage page: Int) {
        collectionViews[page].endRefreshing()
    }
    
    public func showHolderViewWhenErrorOrEmpty(inPage page: Int) {
        collectionViews[page].showHolderView()
    }
    
    public func dismissHolderView(inPage page: Int) {
        collectionViews[page].dismissHolderView()
    }
    
    public func reloadItems(inPage page: Int, indexes: [Int]) {
        guard page < collectionViews.count else {
            return
        }
        collectionViews[0].reloadItems(at: indexes.map{ IndexPath(item: $0, section: 0) })
    }
    
    public func reloadData(forPage page: Int) {
        
        updatePageViews()
        
        guard page < collectionViews.count else {
            return
        }
        
        collectionViews[page].reloadData()
    }
    
    public func reloadDataForCurrentPage() {
        
        updatePageViews()
        
        collectionViews[currentPage].reloadData()
    }
    
    public func reloadDataForAllPages() {
        
        updatePageViews()
        
        collectionViews.forEach {
            $0.reloadData()
        }
    }
    
    public func setCurrentPage(_ page: Int, animated: Bool) {
        currentPage = page
        scrollView.setContentOffset(CGPoint(x: page * Int(scrollView.width), y: 0), animated: animated)
    }
    
    public func selectItem(inPage page: Int, atIndex index: Int) {
        
        let indexPath = IndexPath(item: index, section: 0)
        addIndexPath(indexPath, inPage: page)
        
        collectionViews[page].selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    public func deselectItem(inPage page: Int, atIndex index: Int) {
        
        let indexPath = IndexPath(item: index, section: 0)
        removeIndexPath(indexPath, inPage: page)
        
        collectionViews[page].deselectItem(at: indexPath, animated: false)
    }
    
    public func deselectAllPageItems() {
        for (page, indexPaths) in selectedIndexPathsDict {
            indexPaths.forEach({ collectionViews[page].deselectItem(at: $0, animated: false) })
            selectedIndexPathsDict.removeValue(forKey: page)
        }
    }
    
    public func selectedIndexes(inPage page: Int) -> [Int] {
        if page >= collectionViews.count {
            return []
        }

        guard let indexPaths = selectedIndexPathsDict[page] else {return [] }
        return indexPaths.map({ $0.item })
    }
    
    private func updatePageViews() {
        
        guard let dataSource = dataSource else {
            return
        }
        
        guard collectionViews.count == 0 || dataSource.numberOfPages(in: self) != collectionViews.count else {
            return
        }
        
        collectionViews.removeAll()
        scrollView.subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }

        let containView = UIView().addTo(superView: scrollView).layout { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(self.snp.height)
        }
        var priorCollectionView: UICollectionView? = nil
        
        for page in 0..<dataSource.numberOfPages(in: self) {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
            
            let collectionView = DecorationCollectionView(frame: .zero, collectionViewLayout: flowLayout).addTo(superView: containView).configure { (collectionView) in
                collectionView.backgroundColor = R.color.appColor._e7c99e()
                collectionView.allowsMultipleSelection = true
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.register(cellForClass: DecorationCollectionViewCell.self)
                }.layout { (make) in
                    let _ = priorCollectionView == nil ? make.left.equalToSuperview() : make.left.equalTo(priorCollectionView!.snp.right)
                    make.width.equalTo(UIScreen.main.bounds.width)
                    make.top.bottom.equalToSuperview()
            }

            if dataSource.decorationsView(self, allowsRefreshingForPage:page) {
                collectionView.addRefreshHeader {[unowned self] in
                    self.delegate?.decorationsView(self, didBeginRefeshingInPage: page)
                }
            }
            collectionViews.append(collectionView)
            priorCollectionView = collectionView
        }
        
        containView.snp.makeConstraints { (make) in
            make.right.equalTo(priorCollectionView!.snp.right)
        }
    }
    
    fileprivate func index(of collectionView: UICollectionView) -> Int {
        guard let index = collectionViews.index(of: collectionView as! DecorationCollectionView) else {return currentPage}
        return index
    }
    
    fileprivate func addIndexPath(_ indexPath: IndexPath, inPage page: Int) {
        var existIndexPaths = selectedIndexPathsDict[page]
        if existIndexPaths == nil {
            selectedIndexPathsDict[page] = [indexPath]
        }else {
            existIndexPaths?.append(indexPath)
            selectedIndexPathsDict[page] = existIndexPaths
        }
    }
    
    fileprivate func removeIndexPath(_ indexPath: IndexPath, inPage page: Int) {
        if var existIndexPaths = selectedIndexPathsDict[page] {
            if existIndexPaths.contains(indexPath) {
                existIndexPaths.remove(at: existIndexPaths.index(of: indexPath)!)
                selectedIndexPathsDict[page] = existIndexPaths
            }
        }
    }
}


extension DecorationsView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = dataSource?.decorationsView(self, numberOfItemsInPage: index(of: collectionView)) else { return 0}
        return items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let decorationCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as DecorationCollectionViewCell
        return decorationCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = delegate?.decorationsView(self, sizeForItemInPage: index(of: collectionView), atIndex: indexPath.row) else { return CGSize(width: 44, height: 44)}
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let decorationCell = cell as! DecorationCollectionViewCell
        let page = index(of: collectionView)
        if let reusableViewClass = dataSource?.decorationsView(self, reusableCompomentInPage: page, atIndex: indexPath.row) {
            decorationCell.setReusableViewClass(reusableViewClass)
        }
        decorationCell.reusableView?.configure(withContent: dataSource?.decorationsView(self, contentForItemInPage: index(of: collectionView), atIndex: indexPath.row))
        DebugLog("willDisplay cell: UICollectionViewCell --- index: \(indexPath.item)  isSelected: \(cell.isSelected)")
        
        guard let indexPaths = selectedIndexPathsDict[page] else {
            cell.isSelected = false
            return
        }
        
        let isContain = indexPaths.contains(indexPath)
        decorationCell.reusableView?.set(selected: isContain)
        if !isContain { // Fix bug
            cell.isSelected = isContain
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DebugLog("select \(indexPath)")
        let page = index(of: collectionView)
        addIndexPath(indexPath, inPage: page)
        delegate?.decorationsView(self, didSelectItemInPage: page, atIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        DebugLog("deselect \(indexPath)")
        let page = index(of: collectionView)
        removeIndexPath(indexPath, inPage: page)
        delegate?.decorationsView(self, didDeselectItemInPage: index(of: collectionView), atIndex: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else {
            return
        }
        
        let newPage = lroundf(Float(scrollView.contentOffset.x / scrollView.width))
        if newPage != currentPage {
            currentPage = newPage
            delegate?.decorationsView(self, didChangeTo: currentPage)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.decorationsViewWillBeginDragging(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.decorationsViewDidEndDragging(self)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.decorationsViewWillBeginDecelerating(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DebugLog("scrollViewDidEndDecelerating--------")
        delegate?.decorationsViewDidEndDecelerating(self)
    }
}
