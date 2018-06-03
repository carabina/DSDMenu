//
//  DropDownMenu.swift
//  DropDownMenu
//
//  Created by m3g0byt3 on 27/04/2018.
//  Copyright © 2018 m3g0byt3. All rights reserved.
//

import UIKit

open class DropDownMenu: UIButton {

    // TODO: Add separate constraint for tableView width
    // TODO: Setup with closures instead of delegate
    // TODO: Auto-update view based on selected cell's content
    // TODO: Use POP for cells instead of subclassing
    
    // MARK: - Constants
    
    private static let heightToCornerRadiusRatio: CGFloat = 1 / 25
    private static let shadowOffset = CGSize(width: 1.0, height: 1.0)
    private static let shadowOpacity: Float = 1 / 3
    private static let shadowRadius: CGFloat = 5.0
    private static let shadowColor: UIColor = .black
    private static let animationDuration: TimeInterval = 0.3
    private static let heightConstraintMultiplier: CGFloat = 1.0
    private static let cellIdentifier = "DropDownCell"
    
    // MARK: IBOutlets
    
    public weak var delegate: DropDownDelegate? {
        didSet {
            updateCellClass()
        }
    }
    
    // MARK: - Properties
    
    private let collapsedHeight: CGFloat = 0
    
    private var expandedHeight: CGFloat {
        let rows = delegate?.numberOfItems(in: self) ?? 0
        return bounds.height * CGFloat(rows)
    }
    
    private weak var heightConstraint: NSLayoutConstraint!
    
    private lazy var containerView: UIView = { this in
        this.layer.masksToBounds = false
        this.layer.shadowColor = DropDownMenu.shadowColor.cgColor
        this.layer.shadowOffset = DropDownMenu.shadowOffset
        this.layer.shadowOpacity = DropDownMenu.shadowOpacity
        this.layer.shadowRadius = DropDownMenu.shadowRadius
        return this
    }(UIView())
    
    private lazy var tableView: UITableView = { this in
        this.dataSource = self
        this.delegate = self
        return this
    }(UITableView())
    
    // MARK: - Inits
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Public API
    
    // See https://developer.apple.com/library/content/qa/qa2013/qa1812.html for details.
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Convert the point to the target view's coordinate system.
        // The target view isn't necessarily the immediate subview
        let convertedPoint = self.convert(point, to: tableView)
        
        if tableView.bounds.contains(convertedPoint) {
            // The target view may have its view hierarchy,
            // so call its hitTest method to return the right hit-test view
            return tableView.hitTest(convertedPoint, with: event)
        }
        
        return super.hitTest(point, with: event)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        // Set `separatorStyle = .none` at every subviews layout due to bug https://openradar.appspot.com/21940268
        tableView.separatorStyle = .none
        // Update tableView's row heigt
        tableView.rowHeight = frame.height
        // Update rounded corners for containerView and tableView
        containerView.layer.cornerRadius = containerView.bounds.width * DropDownMenu.heightToCornerRadiusRatio
        tableView.layer.cornerRadius = tableView.bounds.width * DropDownMenu.heightToCornerRadiusRatio
    }
    
    // MARK: - Private API
    
    private func setup() {
        addTarget(self, action: #selector(appearanceUpdate), for: .touchUpInside)
        containerView.addSubview(tableView)
        addSubview(containerView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = NSLayoutConstraint(item: containerView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: DropDownMenu.heightConstraintMultiplier,
                                              constant: collapsedHeight)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightConstraint
        ])
    }
    
    @objc private func appearanceUpdate() {
        let isExpanded = self.heightConstraint.constant > self.collapsedHeight
        
        layoutIfNeeded()
        UIView.animate(withDuration: DropDownMenu.animationDuration) { [unowned self] in
            self.heightConstraint.constant = isExpanded ? self.collapsedHeight : self.expandedHeight
            self.layoutIfNeeded()
        }
    }

    private func updateCellClass() {
        let wrapper = CellClassWrapper(cellClass: delegate?.cellClass(for: self))
        tableView.register(wrapper, forCellReuseIdentifier: DropDownMenu.cellIdentifier)
    }
}

// MARK: - UITableViewDataSource protocol conformance

extension DropDownMenu: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.numberOfItems(in: self) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: DropDownMenu.cellIdentifier, for: indexPath)
    }
}

// MARK: - UITableViewDelegate protocol conformance

extension DropDownMenu: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.dropDownMenu(self, didSelectItemAt: indexPath.row)
        appearanceUpdate()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.dropDownMenu(self, willDisplay: cell as! DropDownCell, forRowAt: indexPath.row)
    }
}
