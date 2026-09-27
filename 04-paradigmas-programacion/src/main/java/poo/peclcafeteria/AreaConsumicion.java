package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Monitor que simula el Area de Consumicion
 * Aforo maximo de 30 clientes
 * Utilizamos ReentratLock con 'fair=true' para garantizar el orden
 */

public class AreaConsumicion {
    
    // Aforo
    private final int aforo = 30;
    
    // Listas GUI
    private List<String> espera = Collections.synchronizedList(new ArrayList<>());
    private List<String> dentro = Collections.synchronizedList(new ArrayList<>());    
    
    // Mecanismos para sincronizacion
    // Utilizamos true para activar la 'justicia' (FIFO)
    private final Lock cerrojo = new ReentrantLock(true);
    private final Condition hayHueco = cerrojo.newCondition();
    
    // Utilidad
    private LoggerCafeteria logger;
    private ControlSimulacion control;
    
    public AreaConsumicion (LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }
    
    // Metodo que simula cuando el cliente intenta entrar para consumir
    // Si hay aforo lleno, entraran por orden de llegada
    public void entrarClientes (String idCliente) throws InterruptedException {
        espera.add(idCliente);
        
        // Al intentar conseguir el cerrojo justo ya se pone en cola en el caso de estar ocupado
        cerrojo.lock();
        
        try {
            // Primero comprobamos si la simulacion esta en pause
            control.comprobarPausa();   
            
            // Esperamos si esta lleno
            // Usamos la condicion del lock para que el await respete el orden
            while (dentro.size() >= aforo) {
                hayHueco.await();
                control.comprobarPausa();
            }
            
            // Si hay hueco, entra
            espera.remove(idCliente);
            dentro.add(idCliente);
            
            logger.log("Cliente " + idCliente + " entra al Area de Consumicion. (Total: " + dentro.size() + ")");
        }
        finally {
            cerrojo.unlock();
        }
    }
    
    // Metodo para simular cuando el cliente termina y sale liberando un hueco
    public void salirCliente (String idCliente) {
        cerrojo.lock();
        
        try {
            dentro.remove(idCliente);
            
            logger.log("Cliente " + idCliente + " sale del Area de Consumicion.");
            
            // Con cerrojos justos signal() despierta solo al que lleva mas tiempo esperando
            hayHueco.signal();
        }
        finally {
            cerrojo.unlock();
        }
    }
    
    // Metodos RMI
    public int getClientesDentro() {
        return dentro.size();
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // GUI Getters
    public String getListaEsperando() { 
        synchronized(espera) { 
            return String.join(", ", espera); 
        } 
    }
    
    public String getListaDentro() { 
        synchronized(dentro) { 
            return String.join(", ", dentro); 
        } 
    }
}