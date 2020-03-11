//
//  CollectionsTableViewController.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

fileprivate let reuseIdentifier = "CollectionsTableViewCell"

struct CollectionRxDataSourceModel: AnimatableSectionModelType, Equatable {

    typealias Identity = String

    typealias Item = Collection
    
    let identity: String
    
    var items: [Item]
    
    init(items: [Item], id: String) {
        self.items = items
        self.identity = id
    }
    
    init(original: CollectionRxDataSourceModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    static func == (lhs: CollectionRxDataSourceModel, rhs: CollectionRxDataSourceModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
}

class CollectionTableViewCell: UITableViewCell {
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        
        return label
    }()
    
    private func setup() {
        backgroundColor = .black
        
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(10)
        }
    }
    
    func configure(text: String) {
        setup()
        label.text = text
    }
    
}


class CollectionTableViewController: UIViewController {
    
    let disposeBag = DisposeBag()
 
    let addPublisher = PublishSubject<Collection>()
    let collectionsPublisher: BehaviorSubject<[Collection]>
    
    init(collections: BehaviorSubject<[Collection]>) {
        self.collectionsPublisher = collections
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        navigationItem.title = "Collections"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCollection))
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<CollectionRxDataSourceModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { dataSource, tableView, indexPath, request in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? CollectionTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.configure(text: request.identity)
                
                return cell
            },
            canEditRowAtIndexPath: { _, _ in true },
            canMoveRowAtIndexPath: { _, _ in true }
        )
        
        let (updateTable,
            shouldPresentRequestVC) =
        CollectionTableViewModel(
            collections: collectionsPublisher,
            itemSelected: tableView.rx.itemSelected.asObservable())

        disposeBag.insert([
            updateTable.bind(to: tableView.rx.items(dataSource: dataSource)),
            shouldPresentRequestVC.bindOnMain(onNext: { [weak self] (vc) in
                self?.navigationController?.pushViewController(vc, animated: true)
            }),
            addPublisher.bind(to: Current.addCollectionPublisher),
            tableView.rx.itemDeleted.map { $0.row }.bind(to: Current.removeCollectionPublisher),
            tableView.rx.itemMoved.map { ($0.row, $1.row) }.bind(to: Current.movePublisher)
        ])
    }
    
    @objc
    func addCollection() {
        addPublisher.onNext(.empty)
    }
}
