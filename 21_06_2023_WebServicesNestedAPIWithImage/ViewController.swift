//
//  ViewController.swift
//  21_06_2023_WebServicesNestedAPIWithImage
//
//  Created by Vishal Jagtap on 03/08/23.
//

import UIKit
import SDWebImage
import Kingfisher

class ViewController: UIViewController {

    var url : URL?
    var urlRequest : URLRequest?
    var urlSession : URLSession?
    var uiNib : UINib?
    var productTableViewCell : ProductTableViewCell = ProductTableViewCell()
    private let resuseIdentifierForProductTableViewCell = "ProductTableViewCell"
    private let urlString = "https://fakestoreapi.com/products"
    var products : [Product] = []
    
    @IBOutlet weak var productTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTableView()
        registerXIBWithTableView()
        url = URL(string: urlString)
        urlRequest = URLRequest(url: url!)
        urlRequest?.httpMethod = "GET"
        urlSession = URLSession(configuration: .default)
        
        parseJSON(urlRequest: urlRequest!, urlSession: urlSession!)
    }
    
    func initializeTableView(){
        productTableView.dataSource = self
        productTableView.delegate = self
    }
    
    func registerXIBWithTableView(){
       uiNib = UINib(nibName: resuseIdentifierForProductTableViewCell, bundle: nil)
        
        self.productTableView.register(uiNib, forCellReuseIdentifier: resuseIdentifierForProductTableViewCell)
    }
    
    func parseJSON(urlRequest : URLRequest, urlSession : URLSession){
        var dataTask = urlSession.dataTask(with: urlRequest) { data, response, error in
            guard let dataReceived = data else {
                return }
            guard let responseReceived = response else { return }
            
            print("Status Code --")
            print(responseReceived)
            
            var jsonResponse = try! JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
            
            for eachJSONObject in jsonResponse{
                let eachObject = eachJSONObject
                let productId = eachObject["id"] as! Int
                let productTitle = eachObject["title"] as! String
                let productPrice = eachObject["price"] as! Double
                let productdescription = eachObject["description"] as! String
                let productCategory = eachObject["category"] as! String
                let productImage = eachObject["image"] as! String
                
                //way 2 for rating
                let productRating = eachObject["rating"] as! [String:Any]
                let productRate = productRating["rate"] as! Double
                let productCount = productRating["count"] as! Int
                
                let newProduct = Product(id: productId,
                                         title: productTitle ?? "ProductTitle",
                                         price: productPrice ?? 200.0,
                                         description: productdescription,
                                         category: productCategory,
                                         image: productImage,
                                         rating: productRating,
                                         rate: productRate,
                                         count: productCount)
                self.products.append(newProduct)
            }
            
            DispatchQueue.main.async {
                self.productTableView.reloadData()
            }
        }
        dataTask.resume()
    }
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        productTableViewCell = self.productTableView.dequeueReusableCell(withIdentifier: resuseIdentifierForProductTableViewCell, for: indexPath) as! ProductTableViewCell
        
        productTableViewCell.productIdLabel.text = String(products[indexPath.row].id)
        productTableViewCell.productPriceLabel.text = String(products[indexPath.row].price)
        productTableViewCell.productCategoryLabel.text = products[indexPath.row].category
        
        productTableViewCell.backgroundColor = UIColor(cgColor: CGColor(red: 50.0, green: 0.0, blue :50.0, alpha: 4.0))
        productTableView.separatorStyle = .singleLine
        productTableView.separatorInset = .init(top: 5.0, left: 7.0, bottom: 5.0, right: 7.0)
        productTableView.separatorColor = .black
        
        let productImageString = products[indexPath.row].image
        
        //SDWebImage -- image downloading and caching
//        productTableViewCell.productImageView.sd_setImage(with: URL(string: productImageString))
        
        //Kingfisher -- image downloading and caching
        productTableViewCell.productImageView.kf.setImage(with: URL(string: productImageString))
        
        return productTableViewCell
    }
}


extension ViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        165.0
    }
}
