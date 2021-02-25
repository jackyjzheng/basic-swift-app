//
//  SelfieListViewController.swift
//  basic-swift-app
//
//  Created by Jacky Zheng on 2/22/21.
//

import UIKit

class SelfieListViewController: UITableViewController {
    var selfies : [Selfie] = []
    var detailViewController: DetailViewController?
    let timeIntervalFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        do
        {
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: { $0.created > $1.created })
        }
        catch let error
        {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1]
                                        as? UINavigationController)?.topViewController
                                        as? DetailViewController
        }
        // Uncomment the follow     ing line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func createNewSelfie()
    {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.sourceType = .camera
            if UIImagePickerController.isCameraDeviceAvailable(.front)
            {
                imagePicker.cameraDevice = .front
            }
        }
        else
        {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func newSelfieTaken(image: UIImage)
    {
        let newSelfie = Selfie(title: "New Selfie")
        newSelfie.image = image
        do
        {
            try SelfieStore.shared.save(selfie: newSelfie)
        }
        catch let error
        {
            showError(message: "Cant save photo: \(error)")
            return
        }
        selfies.insert(newSelfie, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func showError(message: String)
    {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return selfies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let selfie = selfies[indexPath.row]
        cell.textLabel?.text = selfie.title
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date())
        {
            cell.detailTextLabel?.text = "\(interval) ago"
        }
        else
        {
            cell.detailTextLabel?.text = nil
        }
        cell.imageView?.image = selfie.image
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selfieToRemove = selfies[indexPath.row]
            do
            {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                selfies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch
            {
                let title = selfieToRemove.title
                showError(message: "Failed to delete \(title).")
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            return
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SelfieListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true) // Need to understand PickerController control flow better, there should be better place to do this in control flow
        guard let image = info[.originalImage] as? UIImage
        else
        {
            let message = "Couldn't get a picture from the image picker!"
            showError(message: message)
            return
        }
        self.newSelfieTaken(image: image)
        self.dismiss(animated: true, completion: nil)
    }
}
