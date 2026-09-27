package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Monitor que representa y simula la Cocina.
 * Se encarga de controlar el aforo máximo de 100 cocineros.
 */
public class Cocina {

    // Control de aforo
    private final int aforo = 100;
    
    // Lista GUI
    private List<String> cocineros = Collections.synchronizedList(new ArrayList<>());    

    // Utilidad
    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public Cocina(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }

    // SI un cocinero intenta entrar a la cocina y ya hay 100, debe esperar
    public synchronized void entrarCocinero(String idCocinero) throws InterruptedException {
        // 1. Comprobar si el sistema está pausado
        control.comprobarPausa();

        // 2. Control de aforo (Wait mientras esté lleno)
        while (cocineros.size() >= aforo) {
            wait();
        }

        // 3. Entrar
        cocineros.add(idCocinero);
        
        logger.log("Cocinero " + idCocinero + " ha entrado a la cocina. (Total: " + cocineros.size() + ")");
    }

    // SI un cocinero sale, notificamos al resto por si hay alguien esperandp
    public synchronized void salirCocinero(String idCocinero) {
        cocineros.remove(idCocinero);
        
        logger.log("Cocinero " + idCocinero + " sale de la cocina.");
        
        notifyAll(); // Despertamos hilos en espera
    }

    // Metodos para RMI
    public int getCocinerosDentro() {
        return cocineros.size();
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // Getters Gui
    public String getListaCocineros() { 
        synchronized(cocineros) { 
            return String.join(", ", cocineros); 
        } 
    }
}
