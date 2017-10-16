//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import Foundation
import UIKit

protocol  ___VARIABLE_moduleName___VMDelegate: class {
    
}

class ___VARIABLE_moduleName___VM {
    
    weak var application: Application?
    weak var delegate: ___VARIABLE_moduleName___VMDelegate?
    
    init(application: Application) {
        self.application = application
    }
    
}
