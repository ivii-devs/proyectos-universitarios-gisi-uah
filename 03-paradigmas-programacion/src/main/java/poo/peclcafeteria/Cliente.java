package poo.peclcafeteria;

/**
 * Hilo que simula a un Cliente.
 * Ciclo: Parque --> Entrada --> Mostrador --> Caja --> Area Consumo --> Salida
 */
public class Cliente extends Thread {

    private String id;

    // Referencias a los monitores
    private Parque parque;
    private EntradaCafeteria entradaCafeteria;
    private Mostrador mostrador;
    private Caja caja;
    private AreaConsumicion areaConsumicion;

    // Referencias a utilidades
    private LoggerCafeteria logger;
    private ControlSimulacion control;

    public Cliente(String id, Parque parque, EntradaCafeteria entradaCafeteria, Mostrador mostrador, Caja caja, 
                   AreaConsumicion areaConsumicion, LoggerCafeteria logger, ControlSimulacion control) {
        this.id = id;
        this.parque = parque;
        this.entradaCafeteria = entradaCafeteria;
        this.mostrador = mostrador;
        this.caja = caja;
        this.areaConsumicion = areaConsumicion;
        this.logger = logger;
        this.control = control;
    }

    @Override
    public void run() {
        try {
            control.comprobarPausa();

            // 1. PARQUE (Inicio)
            parque.entrar(id);
            logger.log("Cliente " + id + " ha llegado al Parque.");
            
            // Contempla el parque (5 - 10 seg)
            dormir(5000, 10000);
            
            control.comprobarPausa();
            
            // 2. SALE DEL PAQRUE
            parque.salir(id);

            // Trayecto a la cafetería (3 - 9 seg)
            logger.log("Cliente " + id + " ha salido del Parque y camina hacia la Cafeteria.");
            dormir(3000, 9000);

            // 3. ENTRADA A LA CAFETERÍA (Pasillo)
            // Aforo max 20 personas antes del mostrador
            entradaCafeteria.entrar(id);
            logger.log("Cliente " + id + " ha entrado en la CAFETERIA (zona de espera).");            

            // 5. MOSTRADOR (Cola y Pedido)
            // Intentaa entrar al mostrador (Aforo de 5 con cola ordenada)
            mostrador.entrarClientes(id);
            
            // Una vez ya esta en el mostrador, libera su hueco del pasillo
            entradaCafeteria.salir(id);

            // Decide pedido
            int numCafes = (int) (Math.random() * 3) + 1; // 1 a 3
            int numRosquillas = (int) (Math.random() * 5);    // 0 a 4

            logger.log("Cliente " + id + " quiere pedir " + numCafes + " cafes y " + numRosquillas + " rosquillas.");            
            
            // Pedir productos (espera si no hay stock)
            mostrador.cogerProductos(id, numCafes, numRosquillas);

            // Salir del mostrador (deja hueco a otro)
            mostrador.salirCliente(id);

            // 6. CAJA (Pago)
            // Entraa a la cola de caja (Aforo 10 con cola ordenada)
            // Guardamos el ID de la caja asignada
            int idCaja = caja.entrarCliente(id);

            logger.log("Cliente " + id + " pasa a la CAJA " + (idCaja + 1) + ".");            
            
            // Calculamos importe
            double importe = (numCafes * 1.50) + (numRosquillas * 2.50);

            // Proceso de pago (2 - 5 seg)
            control.comprobarPausa();
            dormir(2000, 5000);
            
            // Paga
            caja.pagar(id, idCaja, importe);

            // Sale de la caja
            caja.salirCliente(id, idCaja);

            // 7. AREA DE CONSUMICIÓN
            // Entraa (Aforo 30 con orden de llegada)
            areaConsumicion.entrarClientes(id);

            logger.log("Cliente " + id + " llega al AREA DE CONSUMICION.");            
            
            // Consumir productos (10 - 15 seg)
            control.comprobarPausa();
            logger.log("Cliente " + id + " comienza a consumir sus productos.");
            dormir(10000, 15000);

            // Salir del área
            areaConsumicion.salirCliente(id);

            // 8. SALIDA
            // Liberamos el aforo del pasillo de entrada (las 20 personas)
            entradaCafeteria.salir(id);

            logger.log("Cliente " + id + " sale de la cafeteria.");

        } catch (InterruptedException e) {
            logger.log("Cliente " + id + " interrumpido.");
        }
    }

    private void dormir(int min, int max) throws InterruptedException {
        int tiempo = (int) (Math.random() * (max - min + 1)) + min;
        Thread.sleep(tiempo);
    }
}