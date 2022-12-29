
//
//  ChatViewController.swift
//  teatApp
//
//  Created by streifik on 07.12.2022.
//

import UIKit
import CoreData

class DialogsViewController: UIViewController {

    var messages = [Message1]()
    let dateFormatter = DateFormatter()
    var user = User()
    var users = [User]()
    var userEmail = String()
    var testEmail = String()
    var userName = String()
    var noDialogsLabel = UILabel()
   
    @IBOutlet weak var simulateButton: UIBarButtonItem!
    @IBOutlet weak var dialogsTableView: UITableView!
    
    
    @IBAction func simulateButtonTapped(_ sender: UIBarButtonItem) {
     simulateDialogue()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        print(user)
        loadData()
        dialogsTableView.reloadData()
    }
    
    func fetchUserData() -> User? {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
    
        fetchRequest.predicate = NSPredicate(format: "name = %@", userName)
        do {
            let results = try context.fetch(fetchRequest)

            if let user = results.first as? User {
                return user
                }
            } catch {
                print("Error")
        }
        return nil
    }
    private func fetchChats() -> [Chat]? {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        
        print(userEmail)
        let p1 = NSPredicate(format: "ANY chatEmails.email == %@", "test1@gmail.com")
        let p2 = NSPredicate(format: "ANY chatEmails.email == %@", "\(userEmail)")
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
        
        fetchRequest.predicate = andPredicate

        do {
            let results = try context.fetch(fetchRequest)
            return results as? [Chat]
            
        } catch {
            print("Error")
        }
        return nil
        }
    
    func loadData() {
        messages = []
        print(self.user)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        if let user = fetchUserData() {
            self.user = user
            if let chats = fetchChats() {

                if chats.count == 0 {
                    self.noDialogsLabel = createMessageLabel(text: "No dialogue yet")
                    self.view.addSubview(self.noDialogsLabel)
                } else {
                    self.navigationItem.rightBarButtonItem = nil
                }

            for chat in chats {
                
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message1")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
  
                if let userName = chat.userName {
                fetchRequest.predicate = NSPredicate(format: "chat.userName = %@", userName)
                fetchRequest.fetchLimit = 1
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if let messages = results as? [Message1] {
                      
                        for message in messages {

                            if self.messages.contains(message) {
                                print("Message already exist")
                            } else {
                                self.messages.append(message)
                            }
                        }
                    }
                } catch {
                    print("Error")
                        }
                    }
            
                for chatEmail in chat.chatEmails {
                    if let email = chatEmail.email {
                    if email != self.userEmail {
                
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
                        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
                        
                        do {
                            let results = try context.fetch(fetchRequest)// as? [User]
                            for result in results {
                                let user = result as? User
                                chat.user = user
                            }
                        } catch {
                            print("Error")
                                }
                            }
                        }
                    }
                }
                appdelegate.saveContext()
                
            } else {
                print("no chats")
                    }
                }
            }
    
    func simulateDialogue () {
        print(self.user)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appdelegate.persistentContainer.viewContext
        context.reset()
        let chatsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        
        do{
            let results = try context.fetch(chatsFetchRequest)

            print(results)

              try context.save()
        } catch{
            print("error")
        }
        
        // Set test chat properties
        
        let testEmail = "test1@gmail.com"
        self.testEmail = testEmail
        
        var testUser = User()
        var mailArray = [String]()
        
        guard checkIfItemNotExist(email: testEmail) else {
            print("Item already exist")
            return
        }
        
        let testChat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        let testMessage = NSEntityDescription.insertNewObject(forEntityName: "Message1", into: context) as! Message1
        
        // add test user to coredata
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: context)
        let managedObject = NSManagedObject(entity: entityDescription!, insertInto: context)

        managedObject.setValue("test", forKey: "password")
        managedObject.setValue("test@gmail.com", forKey: "email")
        managedObject.setValue("test", forKey: "name")
        managedObject.setValue("test", forKey: "surname")
        managedObject.setValue(33, forKey: "age")

  
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let results = try context.fetch(usersFetchRequest)
            print(results)
            users = results as! [User]
           
            for result in results as! [NSManagedObject]{

                if let mail = result.value(forKey: "email") as? String {
                    mailArray.append(mail)
                }
            }
        }
        catch {
            print("error")
        }
        
        if mailArray.contains(testEmail) {
            let userIndex = mailArray.firstIndex(where: {$0 == testEmail})
            print(self.users[userIndex!])
            testUser = self.users[userIndex!]
            
            print(testUser)
        }
        
        // set test message properties
        
        testMessage.text = "Hello"
        testMessage.chat = testChat
        testMessage.chat?.userEmail = testEmail
        testMessage.senderName = testUser.name
        testMessage.recieverName = self.userName
        testMessage.senderEmail = "test1@gmail.com"
        testMessage.recieverEmail = self.userEmail
        testMessage.date = Date()
        testChat.user = testUser
        testChat.userName = self.userName
        
        let testChatFirstEmail = NSEntityDescription.insertNewObject(forEntityName: "ChatEmail", into: context) as! ChatEmail
        testChatFirstEmail.email = "test1@gmail.com"
        
        let testChatSecondEmail = NSEntityDescription.insertNewObject(forEntityName: "ChatEmail", into: context) as! ChatEmail
        testChatSecondEmail.email = self.userEmail
        testChatFirstEmail.chat = testChat
        testChatSecondEmail.chat = testChat
        testMessage.chat = testChat
        
        appdelegate.saveContext()
        
        for chatEmail in testChat.chatEmails {
            print(chatEmail)
        }
        
        self.user = testUser
        loadData()
        noDialogsLabel.isHidden = true
        dialogsTableView.reloadData()
        
    }
    
    func createMessageLabel(text: String ) -> (UILabel) {
       
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.6, height: view.frame.height * 0.05))
        label.backgroundColor = UIColor.lightGray
        label.textColor = UIColor.white
        label.font = label.font.withSize(14)
        label.center = view.center
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        
     return label
        }
    
    func checkIfItemNotExist(email: String) -> Bool {

        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
        fetchRequest.predicate = NSPredicate(format: "userEmail == %d" ,email)
       
        do {
            let count = try context.count(for: fetchRequest)
            print(count)
            if count > 0 {
                return false
            } else {
                return true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
            }
        }
    }
    
extension DialogsViewController: UITableViewDataSource, UITableViewDelegate {
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    return self.messages.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
     let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DialogsTableViewCell
    
     let mess = messages.sorted(by: {$0.date! > $1.date!})
    cell.messageLabel.text = mess[indexPath.row].text
    
        cell.nameLabel.text = mess[indexPath.row].chat?.user?.name
    
        if let date =  mess[indexPath.row].date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        cell.timeLabel.text = dateFormatter.string(from: date)
    }
    
    if let userImageData = mess[indexPath.row].chat?.user?.profileImage {
        print(userImageData)
        if userImageData.isEmpty == false {
            cell.avatarImageView.image = UIImage(data: userImageData)
            }
        } else {
            cell.avatarImageView.image = UIImage(named: "defaultImage")
        }
        
        cell.avatarImageView.layer.cornerRadius = 27.5
        cell.selectionStyle = .none
    
        return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let mess = messages.sorted(by: {$0.date! > $1.date!})
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let chatViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            
            if let chat = mess[indexPath.row].chat {
                
                chatViewController.chat = chat
                chatViewController.userEmail = self.userEmail
                
                if  let indexPath = tableView.indexPathForSelectedRow {

                    let currentCell = tableView.cellForRow(at: indexPath) as! DialogsTableViewCell
                    if let name = currentCell.nameLabel.text {
                        chatViewController.userName = name
                    }
                }
                chatViewController.user = self.user
                self.show(chatViewController, sender: self)
                }
            }
        }
    }
