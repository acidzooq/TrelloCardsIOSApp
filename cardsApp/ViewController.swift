//
//  ViewController.swift
//  cardsApp
//
//  Created by hacku on 24/10/2019.
//  Copyright © 2019 Michał Żuczkiewicz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//import OAuthSwift


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var cardDescInput: UITextView!
    @IBOutlet weak var cardNameInput: UITextField!
    @IBOutlet weak var cardsTable: UITableView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var listPicker: UIPickerView!
    
    var json_data: JSON = []
    var to_doIndex = [Int]()
    var doingIndex = [Int]()
    var doneIndex = [Int]()
    let section_names = ["To_do", "Doing","Done"]
    let listsIds = ["5db2b230b644b11d0244038e","5db2b2602b3ac683ef38a283","5db2b277931e8c85dd67d2e7"]
    var selectedList = 0
    var rows_count = [0,0,0]
    var editedId = ""
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editCardButton: UIButton!
    @IBOutlet weak var addCardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardsTable.register(UINib(nibName: "cardsTableViewCell", bundle: nil), forCellReuseIdentifier: "cardsTableViewCell")
        getData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getData()
    {
        getTrello()
    }
    func getTrello()
    {
        let parameters: Parameters = [
            "fields": "all",
            "members": "false",
            "member_fields": "fullName",
            "key": "f3db28244423ed769a88180e6b6ff90f",
            "token": "723721de41d29ceefb64f6afc88944258dc22f85d1eb21447ab25febcae34839"
        ]
        let endPoint: String = "https://api.trello.com/1/boards/JuDGuhkG/cards"
        Alamofire.request(endPoint, parameters: parameters)
            .responseJSON { response in
                let statusCode = response.response?.statusCode
                if response.result.isFailure{
                    
                    print("Error: \(String(describing: response.result.error))")
                    if (statusCode==400)
                    {
                        return
                    }
                    else if(statusCode==403)// || (statusCode==200)
                    {
                        return
                    }
                    
                }
                else if (statusCode==400)
                {
                    return
                }
                else if(statusCode==403)
                {
                    return
                }
                else if (statusCode==200)
                {
                    guard let jsonAsDictionary = response.result.value as? [[String: Any]] else {
                        print("Error: (response.result.error)")
                        return
                    }
                //    defaults.set(JSON(jsonAsDictionary), forKey: "json")
                    if JSON(response.result.value as Any).count>0  //JSON(jsonAsDictionary).arrayObject != nil
                    {
                        self.json_data = JSON(response.result.value as Any)
                        for x in 0...self.json_data.count-1
                        {
                            if (self.json_data[x]["idList"].stringValue==self.listsIds[0])
                            {
                                self.to_doIndex.append(x)
                            }
                            else if (self.json_data[x]["idList"].stringValue==self.listsIds[1])
                            {
                                self.doingIndex.append(x)
                            }
                            else
                            {
                                self.doneIndex.append(x)
                            }
                        }
                        self.rows_count[0] = self.to_doIndex.count
                        self.rows_count[1] = self.doingIndex.count
                        self.rows_count[2] = self.doneIndex.count
                        
                      /*5db2b0910f236255910f9cc5","name":"To Do",
                        5db2b0910f236255910f9cc6","name":"Doing"
                        5db2b0910f236255910f9cc7","name":"Done" */

                        self.cardsTable.reloadData()
                        //self.json_data[0]["id"].stringValue
                       // self.json_data[0]["desc"].stringValue
                    }
                    return
                }
        }
    }
    func clean()
    {
        to_doIndex.removeAll()
        doingIndex.removeAll()
        doneIndex.removeAll()
        rows_count=[0,0,0]
        cardNameInput.text = ""
        cardDescInput.text = ""
        addView.isHidden = true
        addCardButton.isHidden = false
        editCardButton.isHidden = true
        listPicker.isHidden = true
    }
    func numberOfSections(in tableView: UITableView) -> Int {
            return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section_names[section]
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 125      //  }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int{
        return self.rows_count[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var json_index = 0
        var cell : cardsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cardsTableViewCell", for: indexPath) as? cardsTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: "cardsTableViewCell", bundle: nil), forCellReuseIdentifier: "cardsTableViewCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "cardsTableViewCell") as? cardsTableViewCell
            }
            if (indexPath.section == 0)
            {
                json_index = self.to_doIndex[indexPath.row]
            }
            else if (indexPath.section == 1)
            {
                json_index = self.doingIndex[indexPath.row]
            }
            else
            {
                json_index = self.doneIndex[indexPath.row]
            }
             cell.cardTitle?.text = self.json_data[json_index]["name"].stringValue
             cell.descriptionView?.text = self.json_data[json_index]["desc"].stringValue
             cell.editButton.tag = json_index
             cell.editButton.addTarget(self, action:#selector(editItem(_:)), for:.touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            var deletedIndex = 0
            if (indexPath.section == 0)
            {
                deletedIndex = self.to_doIndex[indexPath.row]
                self.to_doIndex.remove(at: indexPath.row)
                self.rows_count[0] = self.to_doIndex.count
            }
            else if (indexPath.section == 1)
            {
                deletedIndex = self.doingIndex[indexPath.row]
                self.doingIndex.remove(at: indexPath.row)
                self.rows_count[1] = self.doingIndex.count
            }
            else
            {
                deletedIndex = self.doneIndex[indexPath.row]
                self.doneIndex.remove(at: indexPath.row)
                self.rows_count[2] = self.doneIndex.count
            }
            let endPoint: String = "https://api.trello.com/1/cards/"+self.json_data[deletedIndex]["id"].stringValue+"?key=f3db28244423ed769a88180e6b6ff90f&token=723721de41d29ceefb64f6afc88944258dc22f85d1eb21447ab25febcae34839"
            Alamofire.request(endPoint, method: .delete)// encoding: JSONEncoding.default) "secret":"ee1132249fd65b8373e578f03b875c3007cb27b3eb41ede9bfbbe83da5c6114e",
                .responseJSON { response in
                    let statusCode = response.response?.statusCode
                    if response.result.isFailure{
                        
                        print("Error: \(String(describing: response.result.error))")
                        if (statusCode==400)
                        {
                            return
                        }
                        else if(statusCode==403)// || (statusCode==200)
                        {
                            return
                        }
                    }
                    else if (statusCode==400)
                    {
                        return
                    }
                    else if(statusCode==403)
                    {
                        return
                    }
                    else if (statusCode==200)
                    {
                        print("ok:")
                    }
            }
            cardsTable.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    @objc func editItem(_ sender: AnyObject)
    {
        let button = sender as? UIButton
        let indexRow = button!.tag
        addView.isHidden = false
        if (listsIds[0] == json_data[indexRow]["idList"].stringValue)
        {
            listPicker.selectRow(0, inComponent:0, animated:true)
        }
        else if (listsIds[1] == json_data[indexRow]["idList"].stringValue)
        {
            listPicker.selectRow(1, inComponent:0, animated:true)
        }
        else
        {
            listPicker.selectRow(2, inComponent:0, animated:true)
        }
        listPicker.isHidden = false
        addCardButton.isHidden = true
        editCardButton.isHidden = false
        cardNameInput.text = self.json_data[indexRow]["name"].stringValue
        cardDescInput.text = self.json_data[indexRow]["desc"].stringValue
        editedId = self.json_data[indexRow]["id"].stringValue
    }
    @IBAction func createNewCard(_ sender: UIButton) {
        addView.isHidden = false
    }
    
    @IBAction func editAction(_ sender: Any) {
        if (cardNameInput.text?.isEmpty)!
        {
            let alert = UIAlertController(title: "Error", message: "Card name is required.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            //  curl --request POST \
            //   --url 'https://api.trello.com/1/cards?idList=5db2b230b644b11d0244038e&name=evercerc&desc=wervwercwrecwercwercwerc&keepFromSource=all&key=f3db28244423ed769a88180e6b6ff90f&token=723721de41d29ceefb64f6afc88944258dc22f85d1eb21447ab25febcae34839'
            let parameters: Parameters = [
                "idList": listsIds[listPicker.selectedRow(inComponent: 0)],
                "name": cardNameInput.text!,
                "desc": cardDescInput.text!,
                "keepFromSource": "all",
                "key": "f3db28244423ed769a88180e6b6ff90f",
                "token": "723721de41d29ceefb64f6afc88944258dc22f85d1eb21447ab25febcae34839"
            ]
            let endPoint: String = "https://api.trello.com/1/cards/" + editedId
            Alamofire.request(endPoint, method: .put, parameters: parameters)
                .responseJSON { response in
                    let statusCode = response.response?.statusCode
                    if response.result.isFailure{
                        
                        print("Error: \(String(describing: response.result.error))")
                        if (statusCode==400)
                        {
                            return
                        }
                        else if(statusCode==403)// || (statusCode==200)
                        {
                            return
                        }
                        
                    }
                    else if (statusCode==400)
                    {
                        return
                    }
                    else if(statusCode==403)
                    {
                        return
                    }
                    else if (statusCode==200)
                    {
                        print("ok")
                        self.clean()
                        self.getData()
                    }
            }
            
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        if (cardNameInput.text?.isEmpty)!
        {
            let alert = UIAlertController(title: "Error", message: "Card name is required.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let parameters: Parameters = [
                "idList": "5db2b230b644b11d0244038e",
                "name": cardNameInput.text!,
                "desc": cardDescInput.text!,
                "keepFromSource": "all",
                "key": "f3db28244423ed769a88180e6b6ff90f",
                "token": "723721de41d29ceefb64f6afc88944258dc22f85d1eb21447ab25febcae34839"
            ]
            let endPoint: String = "https://api.trello.com/1/cards"
            Alamofire.request(endPoint, method: .post, parameters: parameters)
                .responseJSON { response in
                    let statusCode = response.response?.statusCode
                    if response.result.isFailure{
                        
                        print("Error: \(String(describing: response.result.error))")
                        if (statusCode==400)
                        {
                            return
                        }
                        else if(statusCode==403)// || (statusCode==200)
                        {
                            return
                        }
                        
                    }
                    else if (statusCode==400)
                    {
                        return
                    }
                    else if(statusCode==403)
                    {
                        return
                    }
                    else if (statusCode==200)
                    {
                        print("ok")
                        self.clean()
                        self.getData()
                    }
            }

        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        addView.isHidden = true
        addCardButton.isHidden = false
        editCardButton.isHidden = true
        listPicker.isHidden = true
        cardNameInput.text = ""
        cardDescInput.text = ""
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = section_names[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Arial", size: 9.0)!,NSAttributedStringKey.foregroundColor:UIColor.red])
        return myTitle
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedList = row
    }
}

