package poo.peclcafeteria;

/**
 * Hilo que representa al Cocinero
 * Id del tipo B-XXXX
 * Ciclo: Descanso --> Cocina --> Despensa
 */

public class Cocinero extends Thread {
    private String id;
    
    // Referenciamos los lugares (monitores)
    private SalaDescanso salaDescanso;
    private Cocina cocina;
    private Despensa despensa;
    
    // Referencias a utilidades
    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public Cocinero(String id, SalaDescanso salaDescanso, Cocina cocina, Despensa despensa, 
                    LoggerCafeteria logger, ControlSimulacion control) {
        this.id = id;
        this.salaDescanso = salaDescanso;
        this.cocina = cocina;
        this.despensa = despensa;
        this.logger = logger;
        this.control = control;
    }
    
    @Override
    public void run() {
        try {
            while (true) {
                // 1. SALA DE DESCANSO
                salaDescanso.entrarCocinero(id);

                // Descansa durante un tiempo aleatorio entre 5 y 10 seg
                control.comprobarPausa();   
                dormir(5000, 10000);

                salaDescanso.salirCocinero(id);

                // 2. TRAYECTO A LA COCINA (entre 1 y 3 seg)
                control.comprobarPausa();
                dormir(1000, 3000);

                // 3. COCINA
                // Intenta entrar
                cocina.entrarCocinero(id);

                // Prepara los productos (entre 5 y 10 seg)
                control.comprobarPausa();
                dormir(5000, 10000);

                // genera aleatoriamente los productos
                // Cafes --> 2 a 5
                int cafesGenerados = (int) (Math.random() * 4) + 2;

                // Rosquillas --> 4 a 8
                int rosquillasGeneradas = (int) (Math.random() * 5) + 4;

                // Registramos la produccion
                logger.log ("Cocinero " + id + " ha generado " + cafesGenerados + " cafes y " + rosquillasGeneradas + " rosquillas.");

                //sale de la cocina
                cocina.salirCocinero(id);

                // 4. TRAYECTO A DESPENSA (entre 2 y 5 seg)
                control.comprobarPausa();
                dormir(2000, 5000);

                // 5. DESPENSA
                // Entra (aforo 50)
                despensa.entrarCocinero(id);

                // Guarda los productos
                despensa.almacenarProductos(id, cafesGenerados, rosquillasGeneradas);

                // sale de la despensa
                despensa.salirCocinero(id);

                // 6. TRAYECTO DE VUELTA AL DESCANSITO (entre 2 y 5 seg)
                control.comprobarPausa();
                dormir(2000, 5000);
            }
        }
        catch (InterruptedException e) {
            System.err.println("Interrupcion/Excepcion: " + e);
            logger.log("Cocinero " + id + " finaliza su turno.");
        }
    }
    
    // Metodo auxiliar para dormir un tiempo aleatorio
    private void dormir (int min, int max) throws InterruptedException {
        int tiempo = (int) (Math.random() * (max - min + 1)) + min;
        Thread.sleep(tiempo);
    }
}