//
//  ShoppingListCell.swift
//  Lesson 32-Shopping list
//
//  Created by Serhii Prysiazhnyi on 01.11.2024.
//
import UIKit

class ShoppingListCell: UITableViewCell {
    let shoppingLabel = UILabel()
    let checkBox = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Настройка UILabel
        shoppingLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(shoppingLabel)

        // Настройка UISwitch
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkBox)

        // Установка ограничений для элементов
        NSLayoutConstraint.activate([
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shoppingLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            shoppingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            shoppingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

