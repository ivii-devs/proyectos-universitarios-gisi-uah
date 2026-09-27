package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Monitor que simula la entrada a la cafeteria (Zona de espera antes del mostrador)
 * Aforo de 20 personas.
 * Utilizamos ReentrantLock con justicia (fair=true) para mantener el orden de llegada
 */
public class EntradaCafeteria {
    
    // Aforo
    private final int aforo = 20;

    // Listas para la GUI
    // En este caso, "Dentro" del monitor EntradaCafeteria significa "En el pasillo"
    // No hay una cola previa al pasillo visualizada, así que usaremos solo la lista de "dentro".
    private List<String> clientesEnPasillo = Collections.synchronizedList(new ArrayList<>());
    
    // Lock justo para respetar orden de llegada desde la calle
    private final Lock cerrojo = new ReentrantLock(true);
    private final Condition hayHueco = cerrojo.newCondition();

    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public EntradaCafeteria(LoggerCafeteria logger, ControlSimulacion control) {
        this.logger = logger;
        this.control = control;
    }

    public void entrar(String idCliente) throws InterruptedException {
        cerrojo.lock();
        
        try {
            control.comprobarPausa();
            
            while (clientesEnPasillo.size() >= aforo) {
                hayHueco.await();
                control.comprobarPausa();
            }
            clientesEnPasillo.add(idCliente);
            logger.log("Cliente " + idCliente + " entra al pasillo de la Cafeteria. Total: " + clientesEnPasillo.size());
        } 
        finally {
            cerrojo.unlock();
        }
    }

    public void salir(String idCliente) {
        cerrojo.lock();
        
        try {
            clientesEnPasillo.remove(idCliente);
            hayHueco.signal(); // Avisar al siguiente esperando en la calle
        } 
        finally {
            cerrojo.unlock();
        }
    }
    
    public int getClientesDentro() {
        return clientesEnPasillo.size();
    }
    
    /**
     * Como estamos diseñando un sistema multihilo no podemos iterar una lista en la GUI mientras
     * otro hilo la modifica (lanzaría un error). Por ello, los Getters sincronizan la lista y 
     * y devuelven un único String (usando String.join), creando una "foto instantánea" (snapshot)  
     * segura para que la GUI la muestre sin riesgos. 
     */
    
    // GUI Getter
    public String getListaClientes() {
        synchronized(clientesEnPasillo) {
            return String.join(", ", clientesEnPasillo);
        }
    }
}