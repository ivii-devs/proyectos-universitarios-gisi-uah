package poo.peclcafeteria;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;

// Recurso compartido encargado de escribir en el log
// Debe estar sincronizado para evitar que las lineas se mezclen

public class LoggerCafeteria {
    
    private String nombreFichero;
    
    public LoggerCafeteria(String nombreFichero) {
        this.nombreFichero = nombreFichero;
        
        // Al crear el objeto, borramos el contenido anterior del fichero y ponemos una cabecera.
        try {
            // El 'false' en FileWriter indica que NO hacemos append (sobreescribimos el fichero)
            FileWriter fw = new FileWriter(nombreFichero, false);
            PrintWriter pw = new PrintWriter(fw);
            
            pw.println("------ INICIO DE LA SIMULACIÓN ------");
            
            // Es buena práctica cerrar los flujos
            pw.close();
            fw.close();
            
        } catch (IOException e) {
            System.err.println("Error al crear el fichero log: " + e.getMessage());
        }
    }
    
    // Escribimos en el log añadiendo fecha y hora actual
    // Tiene que ser synchronized para que los hilos no escriban a la vez y mezclen lineas
    public synchronized void log (String mensaje) {
        
        // Primero obtenemos la fecha actual
        Date fechaActual = new Date();
        SimpleDateFormat formato = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        String fecha = formato.format(fechaActual);
        
        // "Construimos" la linea de texto con la fecha
        String linea = "[" + fecha + "]" + mensaje;
        
        // Lo mostramos en consola
        System.out.println(linea);
        
        // Lo guardamos en el fichero
        try {
            // El 'true' en FileWriter indica que SÍ hacemos append (añadimos al final sin borrar)
            FileWriter fw = new FileWriter(nombreFichero, true);
            PrintWriter pw = new PrintWriter(fw);
            
            pw.println(linea);
            
            pw.close();
            fw.close();
            
        } catch (IOException e) {
            System.err.println("Error al crear el fichero log: " + e.getMessage());
        }
    }//log
}//class