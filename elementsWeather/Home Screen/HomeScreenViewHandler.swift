//
//  HomeScreenViewHandler.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 30.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

protocol CityChooseDelegate {
    func refreshData()
    func chooseCity(cityId: Int)
}

class HomeScreenViewHandler: NSObject {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModels = [WeatherViewModel]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private let cellIdentifier = "WeatherTableViewCell"
    
    private var delegate: CityChooseDelegate?
    
    var refreshControl = UIRefreshControl()
    
    func configView(delegate: CityChooseDelegate) {
        self.setupTableCell()
        self.setupPullToRefresh()
        self.delegate = delegate
    }
    
    func updateData(data: [WeatherViewModel], refresh: Bool) {
        if refresh {
            self.refreshControl.endRefreshing()
        }
        self.viewModels = data
    }
    
    private func setupTableCell() {
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: self.cellIdentifier)
    }
    
    private func setupPullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refreshData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refreshData(_ sender: AnyObject) {
        self.delegate?.refreshData()
    }
    
}

extension HomeScreenViewHandler: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.chooseCity(cityId: viewModels[indexPath.row].cityId)
    }
}

extension HomeScreenViewHandler: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! WeatherTableViewCell
        cell.fillData(data: viewModels[indexPath.row])
        cell.cityImage.layer.cornerRadius = 15
        cell.layer.cornerRadius = 15
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}


