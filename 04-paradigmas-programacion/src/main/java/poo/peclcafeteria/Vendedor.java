package poo.peclcafeteria;

/**
 * Hilo que representa a un Vendedor.
 * Identificador del tipo V-XXXX
 * Ciclo: Descanso --> Despensa --> Mostrador
 */
public class Vendedor extends Thread {

    private String id;

    // Referencias a los monitores
    private SalaDescanso salaDescanso;
    private Despensa despensa;
    private Mostrador mostrador;

    // utilidades
    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public Vendedor(String id, SalaDescanso salaDescanso, Despensa despensa, Mostrador mostrador,
                    LoggerCafeteria logger, ControlSimulacion control) {
        this.id = id;
        this.salaDescanso = salaDescanso;
        this.despensa = despensa;
        this.mostrador = mostrador;
        this.logger = logger;
        this.control = control;
    }

    @Override
    public void run() {
        try {
            while (true) {
                // 1. SALA DE DESCANSO
                salaDescanso.entrarVendedor(id);

                // Descansan entre 5 y 10 segundos
                control.comprobarPausa();
                dormir(5000, 10000);

                salaDescanso.salirVendedor(id);

                // 2. TRAYECTO A DESPENSA (entre 1 y 3 segundos)
                control.comprobarPausa();
                dormir(1000, 3000);

                // 3. DESPENSA (Recogida de Stock)
                despensa.entrarVendedor(id);

                // Decide cuanto quiere coger:
                // Cafes --> 3 a 6
                int cafesCoge = (int) (Math.random() * 4) + 3;
                
                // Rosquillas --> 5 a 10
                int rosquillasCoge = (int) (Math.random() * 6) + 5;

                // Coge los productos (se bloquea si no hay suficientes)
                // El metodo devuelve lo que hemos cogido (espera hasta tener todo)
                despensa.cogerProductos(id, cafesCoge, rosquillasCoge);

                // Tiempo de preparacion una vez cogidos (1 a 3 segundos)
                control.comprobarPausa();
                dormir(1000, 3000);

                despensa.salirVendedor(id);

                // 4. TRAYECTO A MOSTRADOR
                // Dura entre 2 y 5 segundos
                control.comprobarPausa();
                dormir(2000, 5000);

                // 5. MOSTRADOR (Reposición)
                // Entrar (Aforo 20 vendedores)
                mostrador.entrarVendedor(id);

                // Colocar productos (1 a 3 segundos)
                control.comprobarPausa();
                dormir(1000, 3000);

                // Dejar el stock para los cliente
                mostrador.reponer(id, cafesCoge, rosquillasCoge);

                mostrador.salirVendedor(id);

                // 6. TRAYECTO DE VUELTA A SALA DE DESCANSO
                // Dura entre 2 y 5 segundos
                control.comprobarPausa();
                dormir(2000, 5000);
            }

        } catch (InterruptedException e) {
            System.err.println("Interrupcion/Excepcion: " + e);
            logger.log("Vendedor " + id + " finaliza su turno.");
        }
    }

    // Metodo auxiliar para dormir un tiempo aleatorio
    private void dormir(int min, int max) throws InterruptedException {
        int tiempo = (int) (Math.random() * (max - min + 1)) + min;
        Thread.sleep(tiempo);
    }
}