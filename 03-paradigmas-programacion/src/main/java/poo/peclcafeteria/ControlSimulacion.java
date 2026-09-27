package poo.peclcafeteria;

/**
 * Monitor simple para poder gestionar la Pausa/Reanudación.
 * Los hilos llamaan a comprobarPausa() periodicamente.
 */
public class ControlSimulacion {

    private volatile boolean pausado = true;
    private LoggerCafeteria logger;

    public ControlSimulacion(LoggerCafeteria logger) {
        this.logger = logger;
    }

    public synchronized void pausar() {
        pausado = true;
        logger.log(">>> SIMULACIÓN PAUSADA <<<");
    }

    public synchronized void reanudar() {
        pausado = false;
        notifyAll(); // Despierta a todos los hilos detenidos en wait()
        logger.log(">>> SIMULACIÓN REANUDADA <<<");
    }

    /**
     * Método que ejecutarán los hilos antes de realizar acciones.
     * Si esta pausado, se duermen.
     */
    public synchronized void comprobarPausa() throws InterruptedException {
        while (pausado) {
            wait();
        }
    }
    
    public synchronized boolean controlPause() {
        return pausado;
    }
}