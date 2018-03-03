//
//  ViewController.swift
//  DrawerView
//
//  Created by Mikko Välimäki on 24/10/2017.
//  Copyright © 2017 Mikko Välimäki. All rights reserved.
//

import UIKit
import MapKit
import DrawerView

typealias DrawerMapEntry = (key: String, drawer: DrawerView?)

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var drawerView: DrawerView?

    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var topPanel: UIStackView!

    @IBOutlet weak var locateButtonContainer: UIView!

    var drawers: [DrawerMapEntry] = []

    @objc func toggleTapped(sender: UIButton) {
        let drawer = sender.titleLabel?.text.flatMap { drawers[$0] } ?? nil
        showDrawer(drawer: drawer, animated: true)
    }

    func showDrawer(drawer: DrawerView?, animated: Bool) {
        for d in drawers {
            d.drawer?.setPosition(d.drawer != drawer ? .closed : .collapsed, animated: animated)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        drawers = [
            ("↓", nil),
            ("search", drawerView),
            ("modal", setupProgrammaticDrawerView()),
            ("dark", setupDarkThemedDrawerView()),
            ("toolbar", setupTabDrawerView())
        ]

        self.setupDrawer()
        self.setupToggles()
        self.setupLocateButton()

        showDrawer(drawer: drawerView, animated: false)
    }

    private func setupDrawer() {
        drawerView?.enabledPositions = [.collapsed, .partiallyOpen, .open]
        drawerView?.position = .collapsed
    }

    private func setupToggles() {
        let toggles = drawers
            .map { (key, value) -> UIButton in
                let button = UIButton(type: UIButtonType.system)
                button.addTarget(self, action: #selector(toggleTapped(sender:)), for: .touchUpInside)
                button.setTitle("\(key)", for: .normal)
                button.setTitleColor(UIColor(red: 0, green: 0.5, blue: 0.8, alpha: 0.7), for: .normal)
                button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)!
                return button
        }

        for view in toggles {
            self.topPanel.addArrangedSubview(view)
        }
    }

    private func setupLocateButton() {
        let locateButton = MKUserTrackingButton(mapView: self.mapView)
        locateButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        locateButton.frame = self.locateButtonContainer.bounds
        self.locateButtonContainer.addSubview(locateButton)

        self.locateButtonContainer.layer.borderColor = UIColor(white: 0.2, alpha: 0.2).cgColor
        self.locateButtonContainer.backgroundColor = UIColor(hue: 0.13, saturation: 0.03, brightness: 0.97, alpha: 1.0)
        self.locateButtonContainer.layer.borderWidth = 0.5
        self.locateButtonContainer.layer.cornerRadius = 8
        self.locateButtonContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.locateButtonContainer.layer.shadowRadius = 2
        self.locateButtonContainer.layer.shadowOpacity = 0.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupProgrammaticDrawerView() -> DrawerView {
        // Create the drawer programmatically.
        let drawerView = DrawerView()
        drawerView.attachTo(view: self.view)
        drawerView.enabledPositions = [.closed, .open]
        return drawerView
    }

    func setupDarkThemedDrawerView() -> DrawerView {
        let drawerView = DrawerView()
        drawerView.attachTo(view: self.view)

        drawerView.enabledPositions = [.collapsed, .partiallyOpen]
        drawerView.backgroundEffect = UIBlurEffect(style: .dark)
        return drawerView
    }

    func setupTabDrawerView() -> DrawerView {
        // Attach the drawer with contents of a view controller.
        let drawerView = self.addDrawerView(withViewController:
            self.storyboard!.instantiateViewController(withIdentifier: "TabDrawerViewController")
        )

        drawerView.enabledPositions = [.collapsed, .open]
        drawerView.backgroundEffect = UIBlurEffect(style: .extraLight)
        drawerView.cornerRadius = 0
        // Set the height to match the default toolbar.
        drawerView.collapsedHeight = 44
        return drawerView
    }
}

extension ViewController: DrawerViewDelegate {

    func drawer(_ drawerView: DrawerView, willTransitionFrom position: DrawerPosition) {
        if position == .open {
            searchBar.resignFirstResponder()
        }
    }

    func drawerDidMove(_ drawerView: DrawerView, verticalPosition: CGFloat) {
        let offset = self.view.bounds.height - max(verticalPosition, 150)
        self.additionalSafeAreaInsets.bottom = offset
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Cell \(indexPath.row)"
        cell.backgroundColor = UIColor.clear
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        drawerView?.setPosition(.open, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        drawerView?.setPosition(.open, animated: true)
    }
}
extension Sequence where Element == DrawerMapEntry {

    subscript(key: String) -> DrawerView? {
        return self.first { $0.key == key }?.drawer
    }
}
