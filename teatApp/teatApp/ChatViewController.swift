//
//  ChatViewController.swift
//  teatApp
//
//  Created by streifik on 08.12.2022.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    
    var userEmail = String()
    var userName = String()
    var messages1 = [Message1]()
    var chat = Chat()
    var user = User()
    
    
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        hideKeyboard()
        if sendMessageTextField.text != "" {
        if let text = sendMessageTextField.text {
        self.addMessageToCoreData(text: text)
            self.sendMessageTextField.text = ""
            }
        }
    }
    
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendMessageTextField: UITextField!

    func addMessageToCoreData(text: String) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appdelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
                        fetchRequest.returnsObjectsAsFaults = false
                do{
                      try context.save()
                } catch{
                    print("error")
                }
                
                let message = NSEntityDescription.insertNewObject(forEntityName: "Message1", into: context) as! Message1
                message.chat = self.chat
                message.text = text
                message.senderEmail = self.userEmail
                message.senderName = self.user.name
                message.recieverName = chat.userName
                message.recieverEmail = chat.userEmail  
                message.senderName = self.user.name
                
                let currentDate = Date()
                message.date = currentDate
                 
                appdelegate.saveContext()
            
                self.chat.messages.insert(message)
                chatTableView.reloadData()
                
                do {
                    let results = try context.fetch(fetchRequest)

                    if let chats = results as? [Chat] {
                        for chat in chats {
                            print(chat.messages)
                        }
                    }
                } catch {
                    print("Error")
                }
            }
 
    override func viewDidLoad() {

        super.viewDidLoad()
        sendMessageButton.setImage(UIImage(named: "sendMessage"), for: .normal)
        self.title = userName
        self.chatTableView.separatorStyle = .none
       
   
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        sendMessageTextField.delegate = self
       
       
    }

    override func viewDidAppear(_ animated: Bool) {
         chatTableView.reloadData()
         self.scrollToBottomOfChat()
    }
    override func viewWillDisappear(_ animated: Bool) {
     
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        }
    @objc func keyboardWillShow(notification: NSNotification) {

        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        print(self.messageTextFieldBottomConstraint.constant)
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.messageTextFieldBottomConstraint.constant = (keyboardFrame.size.height - 22)
            print(self.messageTextFieldBottomConstraint.constant)

            self.view.layoutIfNeeded()
            if self.chat.messages.count != 0 {
                self.scrollToBottomOfChat()
            } else {
                print("no messages")
            }
        })
    }
    @objc func keyboardWillHide(notification: NSNotification) {

        messageTextFieldBottomConstraint.constant = -22

        hideKeyboard()
        chatTableView.reloadData()
        if self.chat.messages.count != 0 {
            self.scrollToBottomOfChat()
        } else {
            print("no messages")
        }
    }

    func scrollToBottomOfChat(){
        let indexPath = IndexPath(row: chat.messages.count - 1, section: 0)

            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    func hideKeyboard() {
        sendMessageTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           hideKeyboard()
           return true
       }
}
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chat.messages.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell
    let messages1 = Array(chat.messages.sorted(by: {$0.date! < $1.date!}))
    cell.messageLabel.text = messages1[indexPath.row].text
    
    
    if let date =  messages1[indexPath.row].date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        cell.timeLabel.text = dateFormatter.string(from: date)
    }
    
    if messages1[indexPath.row].senderEmail == userEmail {
        cell.isComing = false
    } else {
        cell.isComing = true
    }
   // self.scrollToBottomOfChat()
    cell.bubleBackgroundView.layer.cornerRadius = 21
    cell.selectionStyle = .none
    
    return cell
    }
}

extension ChatViewController: UITextFieldDelegate {}
