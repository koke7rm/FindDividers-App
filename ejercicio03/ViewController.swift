

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var progessBar: UIProgressView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var proffesor: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configuracion del aspecto del boton
        calculateButton.layer.borderWidth = 1
        calculateButton.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        
        //Solicitamos los permisos de la notificacion
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if granted {
                print("Permiso aceptado")
            }else{
                print("Sin permiso")
                print(error.debugDescription)
            }
        }
    }
    
    @objc func tapGestureHandler(){
        textField.endEditing(true)
    }
    
    
    
    
    // Action del boton que llama a la funcion divisorsCalculator y oculta la imagen 
    @IBAction func calculateButton(_ sender: UIButton) {
        
        divisorsCalculator()
        proffesor.isHidden = true
        tapGestureHandler()
       
    }
    
    // Funcion que se encarga de hacer los calculos para obtener los divisores del numero introducido
    func divisorsCalculator(){
        let number: Int = Int(textField.text ?? "0") ?? 0
        var divisor = 0
        var result = [Int]()
        var percentage = 0
        
        self.progessBar.setProgress(0, animated: false)
        self.percentageLabel.text = ("")
        
        //condicion que comprueba si el campo textField esta vacio, si es asi muestra
        //un error por pantalla
        if (textField.text?.isEmpty ?? true) {
            resultLabel.text = "ERROR!! \n \n No has introducido número"
            
        //condicion que comprueba si el campo textField es mayor que 0
        }else if number <= 0{
            resultLabel.text = "ERROR!! \n \n Tienes que introducir un número entero mayor que 0"
            
            //Si el textField no esta vacio  y el numero introducido es mayor que 0 ejecuta el bucle para comprobar divisores
        }else{
            
            // dispatchQueue para que ejecute los calculos en segundo plano
            DispatchQueue.global().async {
                // para hacer los calculos de los divisores del numero introducido se utiliza un bucle for para ir recorriendo todos los numeros desde el 1 hasta el numero introducido
                for i in 1...number{
                    
                    //si el resto es igual a 0 ese numero es divisible
                    if(number % i == 0){
                        
                        print("\(divisor) \(i)")
                        divisor += 1
                        result.append(i)
                        
                        DispatchQueue.main.async {
                            //Calculo con el que la barra de progreso se ira incrementando
                            self.progessBar.setProgress(Float(i + number - number) / Float(number), animated: true)
                            self.resultLabel.text = ("Calculando...")
                            //Calculo con el que el indicador del porcentaje se ira incrementando
                            percentage = Int((Float(i + number - number)) / (Float (number)) * 100)
                            //El label que muestra el porcentaje se ira actualizando con los resultados que vaya obteniendo la variable percentage
                            self.percentageLabel.text = "\(percentage)%"
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    //Se modifica el label para que muestre por pantalla el resultado del calculo
                    self.resultLabel.text = ("El número \(number) tiene \(divisor) divisiores que son: \n \(result)")
                    
                    //Se ejecuta la notificacion
                    self.showNotification(text: self.resultLabel.text ?? "")
                    
                }
            }
        }
    }
    
    // se crea la funcion para las notificaciones
    func showNotification(text: String){
        let content = UNMutableNotificationContent()
        content.title = "CALCULO TERMINADO!!"
        content.subtitle = "Tu resultado es: "
        content.body = text
        content.sound = .default
        content.badge = 1
        //se crea el trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        //Creamos la request y añadidos el content del trigger
        let request = UNNotificationRequest(identifier: "Mi Notificacion", content: content, trigger: trigger)
        //añadimos la notificacion al centro de notificaciones
        UNUserNotificationCenter.current().add(request) { (error) in
            
            print (error.debugDescription)
        }
    }
    
}

