//
//  ViewController.swift
//  KalturaMeetings
//
//  Copyright © 2020 Kaltura. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import KalturaClient

class ViewController: UIViewController {

    // ----------------------------------------------------------------------------------
    // TODO: Fill in these fields prior to app launch
    
    // User Secret and Partner ID (PID)
    //    * https://kmc.kaltura.com/index.php/kmcng/settings/integrationSettings
    // KAF Endpoint
    //    * Enabled and setup by a Kaltura contact. Usually it contains https://PID.kaf.kaltura.com
    // Resource ID
    //    * Created via scheduleResource API
    //    * https://developer.kaltura.com/console/service/scheduleResource
    let userSecret  = "ENTER_USER_SECRET"
    let partnerId   = ENTER_PARTNER_ID // integer
    let kafEndpoint = "https://ENTER_KAF_ENDPOINT.kaf.kaltura.com/virtualEvent/launch?ks="
    let resourceId  = "ENTER_RESOURCE_ID"
    let userId      = "jane.doe@gmail.com"
    let firstName   = "Jane"
    let lastName    = "Doe"
    // ----------------------------------------------------------------------------------

    // Kaltura Session static params
    let executor: RequestExecutor = USRExecutor.shared
    let config: ConnectionConfiguration = ConnectionConfiguration()
    let type = SessionType.USER
    let expiry = 86400

    // Kaltura client and Kaltura Session
    var kalturaClient:Client? = nil
    var ks = ""
    
    // Role picker data
    let pickerData    = ["-select role-", "instructor", "guest"]
    var bRoleSelected = false

    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.layer.cornerRadius = 5
        
        // Assign the rolePicker delegates.
        self.rolePicker.delegate = self
        self.rolePicker.dataSource = self
        
        // Initialize Kaltura client
        kalturaClient = Client(config)
    }
    
    // IMPORTANT! The Kaltura Session (KS) should be generated on the application backend!
    // This app generates the KS on the client side only for simplicity. Doing this in a
    // production app is a significant security concern...so DON'T DO IT PLEASE!
    func getKalturaSession(isInstructor: Bool) {
        // userContextualRole = 1 ==> host
        // userContextualRole = 3 ==> guest
        let privileges = "userContextualRole:" + (isInstructor ? "1" : "3") +
          ",role:viewerRole" +
          ",resourceId:" + resourceId +
          ",firstName:" + firstName +
          ",lastName:" + lastName

        // Generate a Kaltura Session
        let requestBuilder = SessionService.start(secret: userSecret, userId: userId, type: type,
                                                  partnerId: partnerId, expiry: expiry, privileges: privileges)
        requestBuilder.set(completion: {(result: String?, error: ApiException?) in
            print(result!)
            self.ks = result ?? ""
        })
        executor.send(request: requestBuilder.build(kalturaClient!))
    }

    // Join the Kaltura Meetings room in an embedded Safari browser
    @IBAction func joinRoom(_ sender: Any) {
        // Check if a role is selected
        if bRoleSelected {
            // Launch Kaltura Meetings room in an embedded Safari browser
            if let url = URL(string: self.kafEndpoint + self.ks) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true

                let vc = SFSafariViewController(url: url, configuration: config)
                self.present(vc, animated: true)
            }
        } else {
            print("ERROR! Can't join room without selected role.")
        }
    }
}

// MARK: - UIPickerView extension

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.

        // Generate a new KS if role is selected
        //    * 1st row = instructor
        //    * 2nd row = guest
        if row == 1 {
            self.getKalturaSession(isInstructor:true)
        } else if row == 2 {
            self.getKalturaSession(isInstructor:false)
        }
        bRoleSelected = (row > 0)
    }
}
