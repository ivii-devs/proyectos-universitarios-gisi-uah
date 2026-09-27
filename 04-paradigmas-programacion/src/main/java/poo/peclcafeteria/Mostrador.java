package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Monitor que simula el Mostrador
 * Aforo de 5 clientes (con cola FIFO) y 20 vendedores
 * Gestion de inventario
 */

public class Mostrador {
    
    // Aforos
    private final int aforo_clientes = 5;
    private final int aforo_vendedores = 20;
    
    // Listas para la GUI
    private List<String> clientesEspera = Collections.synchronizedList(new ArrayList<>());
    private List<String> clientesDentro = Collections.synchronizedList(new ArrayList<>());
    private List<String> vendedoresDentro = Collections.synchronizedList(new ArrayList<>());
    
    // Stock
    private int stockRosquillas = 0;
    private int stockCafes = 0;

    // Sincronización Justa
    private final Lock cerrojo = new ReentrantLock(true);
    private final Condition colaClientes = cerrojo.newCondition();
    private final Condition colaVendedores = cerrojo.newCondition();
    private final Condition esperaProductos = cerrojo.newCondition();

    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public Mostrador(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }
    
    /**
     * ZONA DE CLIENTES CON COLA ORDENADA
     */
    public void entrarClientes (String idCliente) throws InterruptedException {
        clientesEspera.add(idCliente); // Entra a esperar
        cerrojo.lock();
        
        try {
            control.comprobarPausa();
            
            while (clientesDentro.size() >= aforo_clientes) {
                colaClientes.await();
                control.comprobarPausa();   
            }
            clientesEspera.remove(idCliente); //Deja de esperar
            clientesDentro.add(idCliente); // Entra
            
            logger.log("Cliente " + idCliente + " ha entrado al Mostrador.");
        } 
        finally {
            cerrojo.unlock();
        }
    }
    
    public void salirCliente(String idCliente) {
        cerrojo.lock();
        
        try {
            clientesDentro.remove(idCliente);
            
            logger.log("Cliente " + idCliente + " ha salido del Mostrador.");            
            
            colaClientes.signal(); // Despierta al siguiente cliente en orden
        } 
        finally {
            cerrojo.unlock();
        }
    }
    
    public void cogerProductos(String idCliente, int numCafe, int numRosquillas) throws InterruptedException {
        cerrojo.lock();
        try {
            control.comprobarPausa();
            while (stockCafes < numCafe || stockRosquillas < numRosquillas) {
                logger.log("Cliente " + idCliente + " esta esperando productos...");
                esperaProductos.await();
                control.comprobarPausa();
            }
            stockCafes -= numCafe;
            stockRosquillas -= numRosquillas;
            logger.log("Cliente " + idCliente + " ha cogido " + numCafe + " cafss y " + numRosquillas + " rosquillas del mostrador.");
        } finally {
            cerrojo.unlock();
        }
    }
    
    // Vendedores
    public void entrarVendedor(String idVendedor) throws InterruptedException {
        // Los vendedores no esperan para entrar al mostrador, trabajan ahí
        cerrojo.lock();
        
        try {
            control.comprobarPausa();
            
            while (vendedoresDentro.size() >= aforo_vendedores) {
                colaVendedores.await();
                control.comprobarPausa();
            }
            vendedoresDentro.add(idVendedor);
            
            logger.log("Vendedor " + idVendedor + " ha entrado al Mostrador.");            
        } 
        finally {
            cerrojo.unlock();
        }
    }

    public void salirVendedor(String idVendedor) {
        cerrojo.lock();
        
        try {
            vendedoresDentro.remove(idVendedor);
            
            logger.log("Vendedor " + idVendedor + " ha salido del Mostrador.");                        
            
            colaVendedores.signal();
        } 
        finally {
            cerrojo.unlock();
        }
    }

    public void reponer(String idVendedor, int numCafe, int numRosquillas) throws InterruptedException {
        cerrojo.lock();
        
        try {
            control.comprobarPausa();
            
            stockCafes += numCafe;
            stockRosquillas += numRosquillas;
            logger.log("Vendedor " + idVendedor + " ha repuesto " + numCafe + " cafes y " + numRosquillas + " rosquillas. Stock: (" + stockCafes + "," + stockRosquillas + ")");
            
            // Avisamos a TODOS los clientes que esperan comida
            esperaProductos.signalAll(); 
        } finally {
            cerrojo.unlock();
        }
    }
    
    // Metodos RMI
    public int getClientes() { 
        return clientesDentro.size(); 
    }
    
    public int getVendedores() { 
        return vendedoresDentro.size(); 
    }
    
    public int getCafe() { 
        return stockCafes; 
    }
    
    public int getRosquillas() { 
        return stockRosquillas; 
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // Getters para la GUI
    public String getListaEsperandoClientes() {
        synchronized(clientesEspera) {
            return String.join(", ", clientesEspera);
        }
    }
    
    public String getListaClientesDentro() {
        return String.join(", ", clientesDentro); 
    }
    
    public String getListaVendedoresDentro() {
        return String.join(", ", vendedoresDentro);
    }
}

