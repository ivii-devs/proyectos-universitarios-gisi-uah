package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Monitor que simula la despensa
 * Actua entre el Cocinero y el Vendedor
 * Los aforos son de 50mcocineros, 50 vendedores.
 * El inventario que hay es de cafes y rosquillas (ilimitados)
 */

public class Despensa {
    // Control de aforo Cocineros
    private final int aforo_cocineros = 50;
    
    // Control de aforo Vendedores
    private final int aforo_vendedores = 50;
    
    // Listas GUI
    private List<String> cocineros = Collections.synchronizedList(new ArrayList<>());
    private List<String> vendedores = Collections.synchronizedList(new ArrayList<>());    
    
    // Inventario
    private int stockCafe = 0;
    private int stockRosquillas = 0;
    
    // Utilidad
    private LoggerCafeteria logger;
    private ControlSimulacion control;
    
    public Despensa(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }
    
    /**
     * ZONA DE LOS COCINEROS
     */
    
    // Metodo que simula cuando el cocinero intenta entrar a la despensa y dejar productos
    public synchronized void entrarCocinero (String idCocinero) throws InterruptedException {
        control.comprobarPausa();
        
        // Si el aforo esta lleno, hay que esperar
        while (cocineros.size() >= aforo_cocineros) {
            logger.log("Cocinero " + idCocinero + " espera para entrar en la Despensa...");
            
            wait();
        }
        cocineros.add(idCocinero);
        
        logger.log("Cocinero " + idCocinero + " ha entrado en la Despensa (Stock: " + stockCafe + ", " + stockRosquillas + ")");

    }
    
    // Metodo para guardar los productos en las estanterias
    // Cuando aumentamos, hay que avisar con notifyAll() a los vendedores que podrian estar esperando
    public synchronized void almacenarProductos (String idCocinero, int cafes, int rosquillas) throws InterruptedException {
        control.comprobarPausa();
        
        stockCafe += cafes;
        stockRosquillas += rosquillas;
        
        logger.log("Cocinero " + idCocinero + " ha guardado " + cafes + " cafes y " + rosquillas + " rosquillas en la Despensa. \n(Stock: " + stockCafe + ", " + stockRosquillas + ")");
        
        // Despertamos a los vendedores que podrian estar esperando por stock
        notifyAll();
    }
    
    // Simulamos cuando el cocinero sale de la despensa
    public synchronized void salirCocinero(String idCocinero) {
        cocineros.remove(idCocinero);

        logger.log("Cocinero " + idCocinero + " ha salido de la Despensa (Stock: " + stockCafe + ", " + stockRosquillas + ")");

        // Avisamos por si otros cocineros quieren entrar
        notifyAll();
    }
    
    /**
     * ZONA DE VENDEDORES
     */
    
    // Simulamos cuando el vendedor intenta entrar a despensa para coger productos
    public synchronized void entrarVendedor (String idVendedor) throws InterruptedException {
        control.comprobarPausa();
        
        // Si el aforo esta lleno esperamos
        while (vendedores.size() >= aforo_vendedores) {
            logger.log("Vendedor " + idVendedor + " espera para entrar en la Despensa...");
            
            wait();
        }
        
        vendedores.add(idVendedor);
        
        logger.log("Vendedor " + idVendedor + " ha entrado en la Despensa (Stock: " + stockCafe + ", " + stockRosquillas + ")");
    }
    
    // Simulamos que el vendedor intenta coger una cantidad n de roductos
    public synchronized void cogerProductos (String idVendedor, int cafesDeseados, int rosquillasDeseadas) throws InterruptedException {
        control.comprobarPausa();
        
        // Si no hay suficiente stock de AMBOS productos, se esperan
        while (stockCafe < cafesDeseados || stockRosquillas < rosquillasDeseadas) {
            logger.log("Vendedor " + idVendedor + " espera stock en Despensa...");
            
            wait();
            
            control.comprobarPausa();
        }
        
        // Cuando hemos comprobado que hay stock suficiente
        stockCafe -= cafesDeseados;
        stockRosquillas -= rosquillasDeseadas;
        
        logger.log("Vendedor " + idVendedor + " retira " + cafesDeseados + " cafes y " + rosquillasDeseadas + " rosquillas de la Despensa.");        
    }
    
    // Simulamos cuando el vendedor sale de la despensa
    public synchronized void salirVendedor (String idVendedor) {
        vendedores.remove(idVendedor);
        
        logger.log("Cocinero " + idVendedor + " ha salido de la Despensa (Stock: " + stockCafe + ", " + stockRosquillas + ")");

        notifyAll();
    }

    // Metodos para RMI    
    public int getCocinerosDentro() { 
        return cocineros.size(); 
    }
    
    public int getVendedoresDentro() { 
        return vendedores.size(); 
    }
    
    public int getStockCafe() { 
        return stockCafe; 
    }
    
    public int getDtockRosquillas() { 
        return stockRosquillas; 
    }

    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // GUI Getters
    public String getListaCocineros() { 
        synchronized(cocineros) { 
            return String.join(", ", cocineros); 
        } 
    }
    
    public String getListaVendedores() { 
        synchronized(vendedores) { 
            return String.join(", ", vendedores); 
        } 
    }
}
