package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Monitor que representa la Sala de Descanso.
 * Aforo ilimitado
 * Sincronizacion necesaria para mantener la consistencia del contador de empleados.
 */
public class SalaDescanso {

    // En este caso utilizamos una lista unificada para mostrar tanto cocineros como vendedores
    private List<String> empleados = Collections.synchronizedList(new ArrayList<>());  
    
    // Contadores internos para RMI
    private int cocinerosDentro = 0;
    private int vendedoresDentro = 0;

    // Utilidades
    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public SalaDescanso(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }

    /**
     * ZONA DE COCINEROS
     */
    
    //Simulamos cuando un cocinero entra a descansar
    // No hay colas de espera
    public synchronized void entrarCocinero (String idCocinero) throws InterruptedException {
        // 1. Comprobamos si el sistema esta pausado
        control.comprobarPausa();

        // 2. Entra
        empleados.add(idCocinero);
        cocinerosDentro++;
        
        logger.log("Cocinero " + idCocinero + " ha entrado a la Sala de Descanso. (Total: " + cocinerosDentro + ")");
    }

    // Simulamos cuando el cocinero sale
    public synchronized void salirCocinero(String idCocinero) {
        empleados.remove(idCocinero);
        cocinerosDentro--;
        
        logger.log("Cocinero " + idCocinero + " ha terminado su descanso.");
        
        notifyAll();
    }
    
    /**
     * ZONA DE VENDEDORES
     */
    
    public synchronized void entrarVendedor(String idVendedor) throws InterruptedException {
        control.comprobarPausa();

        empleados.add(idVendedor);
        vendedoresDentro++;
        
        logger.log("Vendedor " + idVendedor + " ha entrado a la Sala de Descanso. (Total: " + vendedoresDentro + ")");
    }

    public synchronized void salirVendedor(String idVendedor) {
        empleados.remove(idVendedor);
        vendedoresDentro--;
        
        logger.log("Vendedor " + idVendedor + " ha terminado su descanso.");

        notifyAll();
    }
    
    // Metodos RMI
    public int getCocinerosDentro() { 
        return cocinerosDentro; 
    }
    
    public int getVendedoresDentro() { 
        return vendedoresDentro; 
    }
    
    public int getTotalEmpleados() { 
        return cocinerosDentro + vendedoresDentro; 
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // GUI
    public String getListaTodos() { 
        synchronized(empleados) { 
            return String.join(", ", empleados); 
        } 
    }
}