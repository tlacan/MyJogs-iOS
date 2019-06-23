//
//  RecordViewController.swift
//  MyJogs
//
//  Created by thomas lacan on 12/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

class RecordViewController: UITableViewController {
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "View Controller Records"
        let rightItem = UIBarButtonItem(title: "Créer",
                                        style: .done,
                                        target: self,
                                        action: #selector(addJog))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        engine.jogsService.refreshJogs()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engine.jogsService.jogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = UITableViewCell(style: .default, reuseIdentifier: "jambon")
        basicCell.textLabel?.text = "cell \(indexPath.row)"
        return basicCell
    }
    
    @objc func addJog() {
        engine.jogsService.createJog(engine.jogsService.createRandomModel()) { [weak self](error) in
            if error != nil {
                let alertController = UIAlertController(title: nil,
                                                        message: "Une erreur est survenue",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            self?.tableView.reloadData()
        }
    }
}

extension RecordViewController: JogsServiceObserver {
    func onJogService(jogService: JogsService, didUpdate state: ServiceState) {
        if state == .loaded {
            tableView.reloadData()
        }
    }
}
