//
//  SectionTableViewCell.swift
//  Articles
//
//  Created by Dwistari on 15/04/25.
//

import UIKit
import SDWebImage

class SectionTableViewCell: UITableViewCell {
    
    private var imageUrl: [String] = []
  
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 120, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with url: [String]) {
        self.imageUrl = url
        collectionView.reloadData()
    }
        
    private func setupViews() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
}

extension SectionTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { imageUrl.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .gray
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 50, y: 100, width: 200, height: 200)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        let url = URL(string: imageUrl[indexPath.row])
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.large
        imageView.sd_setImage(with: url,placeholderImage: UIImage(systemName: "photo"), options: [.retryFailed, .continueInBackground])
        return cell
    }
}

enum SectionState {
    case loading
    case loaded([ResponseModel])
    case failed(Error)
}
