//
//  ViewController.swift
//  CookpadWeatherApp
//
//  Created by Pushpak Athawale on 27/11/16.
//  Copyright © 2016 com.pushpak. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var showWeatherButton: UIButton!
    @IBOutlet weak var currentLocationTextField: UITextField!
    
    var numberToDisplay:Int = 0
    
    let weatherArray:NSMutableArray = []
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.weatherTableView.dataSource = self
        self.weatherTableView.delegate = self
        showWeatherButton.addTarget(self, action: #selector(showWeather), for: .touchDown)
        
        
        weatherTableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        
        
        
        
    }

    
    
    func showWeather(){
        if let currentLocation = currentLocationTextField.text{
            
            let apiURL = "http://api.openweathermap.org/data/2.5/forecast/daily?q=\(currentLocation)&units=metric&cnt=7&APPID=2eba03e4aac77500b3b60e361715b3f7"
            
            SVProgressHUD.show(withStatus: "Fetching weather data!")
            
            Alamofire.request(apiURL).responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    self.weatherArray.removeAllObjects()
                    if let list = json["list"].array{
                        for index in list{
                            let tempObj = weatherObj()
                            tempObj.dt = index["dt"].int32!
                            tempObj.maxTemp = index["temp"]["max"].double!
                            tempObj.minTemp = index["temp"]["min"].double!
                            tempObj.main = index["weather"][0]["main"].string!
                            tempObj.detail = index["weather"][0]["description"].string!
                            self.weatherArray.add(tempObj)
                        }
                        
                        SVProgressHUD.dismiss()
                        
                        switch self.segmentedControl.selectedSegmentIndex{
                        case 0:
                            self.numberToDisplay = 2
                            self.weatherTableView.reloadData()
                        case 1:
                            //                showWeeklyWeather(currentLocation: currentLocation)
                            self.numberToDisplay = 7
                            self.weatherTableView.reloadData()
                        default:
                            self.numberToDisplay = 2
                            self.weatherTableView.reloadData()
                        }

                        
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    SVProgressHUD.dismiss()
                }
                
            }

          }else{
            //enter valid location
        }
        
    }
    
//    func showCurrentWeather(currentLocation:String){
//        let apiURL = "http://api.openweathermap.org/data/2.5/weather?q=\(currentLocation)&APPID=2eba03e4aac77500b3b60e361715b3f7"
//        
//            }
//    
//    
//    func showWeeklyWeather(currentLocation:String){
//        
//    }
//   

    @IBAction func change(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex{
        case 0:
            self.numberToDisplay = 2
            self.weatherTableView.reloadData()
        case 1:
            //                showWeeklyWeather(currentLocation: currentLocation)
            self.numberToDisplay = 7
            self.weatherTableView.reloadData()
        default:
            self.numberToDisplay = 2
            self.weatherTableView.reloadData()
        }
        
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberToDisplay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as! WeatherTableViewCell
        
        let tempObj = weatherArray.object(at: indexPath.row) as! weatherObj
        
        let dt = tempObj.dt!
        let date = NSDate(timeIntervalSince1970: TimeInterval(dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let string = dateFormatter.string(from: date as Date)
        
        if indexPath.row == 0{
            cell.dateString.text = "Today"
        }else if indexPath.row == 1{
            cell.dateString.text = "Tomorrow"
        }else{
            cell.dateString.text = string
        }
        cell.tempLabel.text = "Max \(tempObj.maxTemp!) \u{00B0}C / Min \(tempObj.minTemp!)\u{00B0}C"
        cell.detailLabel.text = "\(tempObj.detail!)"
        
        return cell
    }
    
    
}

class weatherObj:NSObject{
    var dt:Int32!
    var maxTemp:Double!
    var minTemp:Double!
    var main:String!
    var detail:String!
}

