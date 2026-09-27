package poo.peclcafeteria;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Parque {
    // Usamos una lista sincronizada para guardar los IDs
    private List<String> clientesEnParque = Collections.synchronizedList(new ArrayList<>());
    private LoggerCafeteria logger;

    public Parque(LoggerCafeteria logger) {
        this.logger = logger;
    }

    public void entrar(String id) {
        clientesEnParque.add(id);
    }

    public void salir(String id) {
        clientesEnParque.remove(id);
    }

    // Devuelve la lista como String para la GUI: "C-001, C-002..."
    public String getListaClientes() {
        synchronized(clientesEnParque) {
            return String.join(", ", clientesEnParque);
        }
    }
    
    public int getCantidad() {
        return clientesEnParque.size();
    }
}