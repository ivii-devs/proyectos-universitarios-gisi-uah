package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Esta clase es un Monitor que representa la zona de las Cajas
 * Controla el aforor (10 clientes) y acumula el dinero
 */

public class Caja {
    
    //Atributos de aforo
    private final int aforo = 10;
    
    // Decidimos crear un Array para controlar el estado de cada caja individualmente (true = libre)
    // Hay 10 Cajas --> IDs del 0 al 9
    private boolean[] cajasLibres;
    
    // Dinero (Este es el Recurso Compartido)
    private double dineroTotal = 0.0;
    
    // Listas GUI
    private List<String> espera = Collections.synchronizedList(new ArrayList<>());
    private List<String> dentro = Collections.synchronizedList(new ArrayList<>());    
    
    // mecanismo para sincronizacion justa
    private final Lock cerrojo = new ReentrantLock(true); // true = FIFO (Orden de llegada)
    private final Condition hayHueco = cerrojo.newCondition();
    
    // Otros
    private LoggerCafeteria logger;
    private ControlSimulacion control;
    
    public Caja(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
        
        // Inicializamos las cajas
        this.cajasLibres = new boolean[aforo];
        for (int i = 0; i < aforo; i++) {
            cajasLibres[i] = true;
        }
    }
    
    // Metodo que simula que el cliente intenta entrar a la zona de Cajas
    // SI las 10 cajas estan ocupadas, se bloquea con wait
    public int entrarCliente (String idCliente) throws InterruptedException {
        espera.add(idCliente);
        
        cerrojo.lock(); // Nos ponemos en la cola (FIFO)
        
        try {
            // comprobamos si esta pausado
            control.comprobarPausa();

            // Comprobamos aforo
            while (dentro.size() >= aforo) {
                hayHueco.await(); //Esperamos a que salga alguien
                control.comprobarPausa();
            }
            
            // Entrar (ocupamos caja)
            espera.remove(idCliente);
            dentro.add(idCliente);

            // Buscamos una maquina que este libre
            int idCajaAsignada = -1;
            for (int i = 0; i < aforo; i++) {
                if (cajasLibres[i] == true) {
                    idCajaAsignada = i;
                    cajasLibres[i] = false; // Se queda ocupada
                    break; // Ya encontramos caja libre --> dalimos del bucle
                }
            }
            
            // Registramos la entrada en el log
            logger.log("El cliente " + idCliente + " ha accedido a Caja " + (idCajaAsignada + 1));
            
            return idCajaAsignada;
        }
        finally {
            cerrojo.unlock();
        }
    }
    
    // Metodo que simula el pago.
    public  void pagar (String idCliente, int idCaja, double importe) throws InterruptedException {
        cerrojo.lock();
        
        try {
            control.comprobarPausa();
            
            dineroTotal += importe;

            // Aqui hemos utilizado String.format para que el dinero salga bonito con 2 decimales
            String importeTexto = String.format("%.2f", importe);
            String totalTexto = String.format("%.2f", dineroTotal);

            // Lo registramos en el log
            logger.log("Cliente " + idCliente + " ha pagado " + importeTexto + "€ en la Caja " + (idCaja + 1) + "\nRecaudacion Total: " + totalTexto + "€.");
        }
        finally {
            cerrojo.unlock();
        }
    }
    
    // Metodo que simula cuando el cliente se va de la caja
    // Aqui usamos notifyAll para despertar a los que estan esperando para entrar
    public synchronized void salirCliente (String idCliente, int idCaja) {
        cerrojo.lock();
        
        try {
            //Liberamos la caja
            cajasLibres[idCaja] = true;
            dentro.remove(idCliente);

            logger.log("El cliente " + idCliente + " ha salido de la Caja " + (idCaja +1));
            
            // Avisamos al siguiente en la cola
            hayHueco.signal();
        }
        finally {
            cerrojo.unlock();
        }
    }
    
    // Metodos para RMI
    public synchronized int getClientesDentro() {
        return dentro.size();
    }
    
    public synchronized double getDineroTotal() {
        return dineroTotal;
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // Getetrs para la GUI
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