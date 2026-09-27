package poo.peclcafeteria;

import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.Font;
import java.rmi.Naming;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.server.UnicastRemoteObject;
import javax.swing.*;
import javax.swing.border.EmptyBorder;

/**
 * SERVIDOR (Clase PRINCIPAL)
 * Inicializa todos los Monitores (Recursos Compartidos).
 * Levanta la Interfaz Gráfica (GUI) del Servidor.
 * Inicia el servicio RMI.
 * Lanza los hilos (Clientes, Cocineros, Vendedores).
 */
public class ServidorCafeteria extends UnicastRemoteObject implements InterfazMonitorCafeteria {

    // Recursos Compartidos
    private LoggerCafeteria logger;
    private ControlSimulacion control;
    
    // Monitores
    private Parque parque;
    private EntradaCafeteria entradaCafeteria;
    private Mostrador mostrador;
    private Caja caja;
    private Cocina cocina;
    private Despensa despensa;
    private SalaDescanso salaDescanso;
    private AreaConsumicion areaConsumicion;

    // ELEMENTOS DE LA GUI
    private JFrame frame;
    private JButton btnPausar;
    
    // Campos de texto para mostrar el estado
    private JTextArea txtParque, txtEntrada, txtEsperandoMostrador;
    private JTextArea txtMostradorClientes, txtMostradorVendedores;
    private JTextArea txtEsperandoCaja, txtCaja;
    private JTextArea txtEsperandoConsumo, txtAreaConsumo;
    
    private JTextArea txtCocina;
    private JTextArea txtDespensaCocineros, txtDespensaVendedores;
    private JTextArea txtSalaDescanso;
    
    // Stock y Dinero
    private JTextField txtStockCafeDespensa, txtStockRosquillasDespensa;
    private JTextField txtStockCafeMostrador, txtStockRosquillasMostrador;
    private JTextField txtRecaudacion;

    // Contadores para generadores (solo para visualización/log)
    private int contadorClientesGenerados = 0;

    public ServidorCafeteria() throws RemoteException {
        super(); // Necesario para RMI
        
        // 1. Inicializar Logger y Control
        logger = new LoggerCafeteria("evolucion_cafeteria.txt");
        control = new ControlSimulacion(logger);

        // 2. Inicializar Monitores
        // El orden no importa mucho, pero deben estar antes de usarse
        parque = new Parque(logger);
        entradaCafeteria = new EntradaCafeteria(logger, control);
        mostrador = new Mostrador(logger, control);
        caja = new Caja(logger, control);
        cocina = new Cocina(logger, control);
        despensa = new Despensa(logger, control);
        salaDescanso = new SalaDescanso(logger, control);
        areaConsumicion = new AreaConsumicion(logger, control);
        
        // 3. Crear la Interfaz Gráfica
        crearInterfaz();

        // 4. Iniciar Timer para actualizar la GUI localmente
        // Esto evita tener que pasar los JTextFields a cada monitor.
        // Consultamos los datos cada 100ms y refrescamos la pantalla.
        Timer timerGUI = new Timer(100, e -> actualizarInterfaz());
        timerGUI.start();
        
        logger.log("Servidor inicializado y GUI arrancada.");
    }

    
    // Configura la ventana y los componentes gráficos.
    private void crearInterfaz() {
        frame = new JFrame("Simulación Cafetería - Servidor");
        frame.setSize(1200, 850);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new BorderLayout());

        // Panel Superior (Control)
        JPanel top = new JPanel();
        btnPausar = new JButton("INICIAR SIMULACIÓN");
        btnPausar.addActionListener(e -> togglePausa());
        top.add(btnPausar);
        frame.add(top, BorderLayout.NORTH);

        // CENTRO (2 Columnas)
        JPanel centro = new JPanel(new GridLayout(1, 2, 10, 10));
        centro.setBorder(new EmptyBorder(10, 10, 10, 10));

        // IZQUIERDA
        // Usamos GridLayout vertical para que todos los paneles tengan el mismo tamaño
        JPanel izq = new JPanel(new GridLayout(0, 1, 0, 5)); 
        
        txtParque = addScrollableSection(izq, "Parque");
        txtEntrada = addScrollableSection(izq, "Entrada Cafetería (Pasillo)");
        txtEsperandoMostrador = addScrollableSection(izq, "Esperando Mostrador");
        txtMostradorClientes = addScrollableSection(izq, "Mostrador (Clientes)");
        
        // Agrupamos Caja y Espera Caja en un sub-panel para ahorrar espacio 
        txtEsperandoCaja = addScrollableSection(izq, "Esperando Caja");
        txtCaja = addScrollableSection(izq, "Caja");
        
        txtEsperandoConsumo = addScrollableSection(izq, "Esperando para consumir");
        txtAreaConsumo = addScrollableSection(izq, "Área de Consumición");
        
        // Recaudación es pequeño, lo añadimos al final 
        JPanel pRecaudacion = new JPanel(new BorderLayout());
        pRecaudacion.add(new JLabel("Recaudación: "), BorderLayout.WEST);
        txtRecaudacion = new JTextField();
        txtRecaudacion.setEditable(false);
        txtRecaudacion.setFont(new Font("Arial", Font.BOLD, 16));
        txtRecaudacion.setForeground(new Color(0, 100, 0));
        pRecaudacion.add(txtRecaudacion, BorderLayout.CENTER);
        // Lo metemos en un panel wrapper para que no se estire demasiado si usamos GridLayout
        JPanel pRecWrapper = new JPanel(new BorderLayout());
        pRecWrapper.add(pRecaudacion, BorderLayout.NORTH);
        izq.add(pRecWrapper);

        // DERECHA (Empleados) 
        JPanel der = new JPanel(new GridLayout(0, 1, 0, 10));

        txtCocina = addScrollableSection(der, "Cocina");
        
        // Despensa (Compleja: Cocineros + Vendedores + Stock)
        JPanel pDespensa = new JPanel(new BorderLayout());
        pDespensa.setBorder(BorderFactory.createTitledBorder("Despensa"));
        
        // Panel central de despensa para las listas (Grid 2 columnas)
        JPanel pDespensaListas = new JPanel(new GridLayout(1, 2, 5, 0));
        txtDespensaCocineros = createTextArea();
        txtDespensaVendedores = createTextArea();
        pDespensaListas.add(createScrollPanel("Cocineros", txtDespensaCocineros));
        pDespensaListas.add(createScrollPanel("Vendedores", txtDespensaVendedores));
        pDespensa.add(pDespensaListas, BorderLayout.CENTER);

        // Stock Despensa (Abajo)
        JPanel pStockD = new JPanel(new FlowLayout(FlowLayout.LEFT));
        txtStockCafeDespensa = new JTextField(5); txtStockRosquillasDespensa = new JTextField(5);
        pStockD.add(new JLabel("Cafés:")); pStockD.add(txtStockCafeDespensa);
        pStockD.add(new JLabel("Rosq:")); pStockD.add(txtStockRosquillasDespensa);
        pDespensa.add(pStockD, BorderLayout.SOUTH);
        der.add(pDespensa);

        // Mostrador Vendedores
        JPanel pMostradorV = new JPanel(new BorderLayout());
        pMostradorV.setBorder(BorderFactory.createTitledBorder("Mostrador (Vendedores y Stock)"));
        txtMostradorVendedores = createTextArea();
        pMostradorV.add(new JScrollPane(txtMostradorVendedores), BorderLayout.CENTER);
        
        JPanel pStockM = new JPanel(new FlowLayout(FlowLayout.LEFT));
        txtStockCafeMostrador = new JTextField(5); txtStockRosquillasMostrador = new JTextField(5);
        pStockM.add(new JLabel("Cafés:")); pStockM.add(txtStockCafeMostrador);
        pStockM.add(new JLabel("Rosq:")); pStockM.add(txtStockRosquillasMostrador);
        pMostradorV.add(pStockM, BorderLayout.SOUTH);
        der.add(pMostradorV);
        
        txtSalaDescanso = addScrollableSection(der, "Sala de Descanso");

        centro.add(izq);
        centro.add(der);
        frame.add(centro, BorderLayout.CENTER);
        frame.setVisible(true);
    }

    // Método helper para crear un panel con titulo y JTextArea con Scroll
    private JTextArea addScrollableSection(JPanel parent, String title) {
        JTextArea ta = createTextArea();
        JPanel panel = createScrollPanel(title, ta);
        parent.add(panel);
        return ta;
    }

    private JTextArea createTextArea() {
        JTextArea ta = new JTextArea();
        ta.setEditable(false);
        ta.setLineWrap(true);       // Ajuste de línea automático
        ta.setWrapStyleWord(true);  // Cortar por palabras completas
        ta.setBackground(Color.WHITE);
        return ta;
    }

    private JPanel createScrollPanel(String title, JTextArea ta) {
        JPanel p = new JPanel(new BorderLayout());
        p.setBorder(BorderFactory.createTitledBorder(title)); // Borde con título
        JScrollPane scroll = new JScrollPane(ta);
        // Barra vertical siempre visible si hace falta, horizontal nunca (gracias al wrap)
        scroll.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED);
        scroll.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
        p.add(scroll, BorderLayout.CENTER);
        return p;
    }
    
    // Actualiza los valores de la GUI leyendo los monitores.
    private void actualizarInterfaz() {
        txtParque.setText(parque.getListaClientes());
        txtEntrada.setText(entradaCafeteria.getListaClientes());
        
        txtEsperandoMostrador.setText(mostrador.getListaEsperandoClientes());
        txtMostradorClientes.setText(mostrador.getListaClientesDentro());
        txtMostradorVendedores.setText(mostrador.getListaVendedoresDentro());
        
        txtEsperandoCaja.setText(caja.getListaEsperando());
        txtCaja.setText(caja.getListaDentro());
        
        txtEsperandoConsumo.setText(areaConsumicion.getListaEsperando());
        txtAreaConsumo.setText(areaConsumicion.getListaDentro());
        
        txtCocina.setText(cocina.getListaCocineros());
        
        txtDespensaCocineros.setText(despensa.getListaCocineros());
        txtDespensaVendedores.setText(despensa.getListaVendedores());
        txtStockCafeDespensa.setText(String.valueOf(despensa.getStockCafe()));
        txtStockRosquillasDespensa.setText(String.valueOf(despensa.getDtockRosquillas()));
        
        txtStockCafeMostrador.setText(String.valueOf(mostrador.getCafe()));
        txtStockRosquillasMostrador.setText(String.valueOf(mostrador.getRosquillas()));
        
        txtSalaDescanso.setText(salaDescanso.getListaTodos());
        txtRecaudacion.setText(String.format("%.2f €", caja.getDineroTotal()));
    }

    private void togglePausa() {
        // Logica del boton de PAUSE
        // La logica real de pausa está en ControlSimulacion, pero necesitamos saber su estado
        try {
            if (control.controlPause()) {
                // Si estaba pausado --> REANUDAR
                control.reanudar();
                btnPausar.setText("PAUSAR SIMULACIÓN");
                btnPausar.setBackground(new Color(255, 200, 200));
            }
            else {
                // SI estaba corriendo --> PAUSAR
                control.pausar();
                btnPausar.setText("REANUDAR SIMULACIÓN");
                btnPausar.setBackground(new Color(200, 255, 200));
            }
        } 
        catch (Exception e) {}
    }

    // Método principal que lanza los hilos     
    public void iniciarSimulacion() {
        
        // 1. Generador de CLIENTES (8000)
        new Thread(() -> {
            try {
                for (int i = 1; i <= 8000; i++) {
                    control.comprobarPausa();
                    
                    String id = String.format("C-%04d", i);
                    contadorClientesGenerados++;
                    
                    Cliente c = new Cliente(id, parque, entradaCafeteria, mostrador, caja, areaConsumicion, logger, control);
                    c.start();

                    // Intervalo 1 - 3 segundos
                    Thread.sleep((int)(Math.random() * 2001) + 1000);
                }
            } catch (InterruptedException e) { e.printStackTrace(); }
        }).start();

        // 2. Generador de VENDEDORES (500)
        new Thread(() -> {
            try {
                for (int i = 1; i <= 500; i++) {
                    control.comprobarPausa();
                    
                    String id = String.format("V-%04d", i);
                    
                    Vendedor v = new Vendedor(id, salaDescanso, despensa, mostrador, logger, control);
                    v.start();

                    // Intervalo 0.5 - 2.5 segundos (500 - 2500 ms)
                    Thread.sleep((int)(Math.random() * 2001) + 500);
                }
            } catch (InterruptedException e) { e.printStackTrace(); }
        }).start();

        // 3. Generador de COCINEROS (500)
        new Thread(() -> {
            try {
                for (int i = 1; i <= 500; i++) {
                    control.comprobarPausa();
                    
                    String id = String.format("B-%04d", i); // 'B' de Baker? O Cocinero.
                    
                    Cocinero c = new Cocinero(id, salaDescanso, cocina, despensa, logger, control);
                    c.start();

                    // Intervalo 1 - 2 segundos
                    Thread.sleep((int)(Math.random() * 1001) + 1000);
                }
            } catch (InterruptedException e) { e.printStackTrace(); }
        }).start();
    }

    // IMPLEMENTACIÓN RMI (InterfazMonitorCafeteria)
    // Estos métodos son llamados remotamente por el Cliente
    
    @Override
    public boolean estaPausado() throws RemoteException {
        return control.controlPause();
    }

    @ Override
    public void pausar() throws RemoteException {
        control.pausar();
        btnPausar.setText("REANUDAR SIMULACIÓN"); // Actualizar botón local
        btnPausar.setBackground(new Color(200, 255, 200));
    }

    @Override
    public void reanudar() throws RemoteException {
        control.reanudar();
        btnPausar.setText("PAUSAR SIMULACIÓN");
        btnPausar.setBackground(new Color(255, 200, 200));        
    }

    // Delegamos en los monitores
    public int getClientesEnParque() throws RemoteException { return parque.getCantidad(); }
    public int getClientesEnMostrador() throws RemoteException { return mostrador.getClientes(); }
    public int getClientesEnCaja() throws RemoteException { return caja.getClientesDentro(); }
    public int getClientesEnAreaConsumicion() throws RemoteException { return areaConsumicion.getClientesDentro(); }
    
    public int getCocinerosEnCocina() throws RemoteException { return cocina.getCocinerosDentro(); }
    public int getCocinerosEnDespensa() throws RemoteException { return despensa.getCocinerosDentro(); }
    public int getVendedoresEnDespensa() throws RemoteException { return despensa.getVendedoresDentro(); }
    public int getVendedoresEnMostrador() throws RemoteException { return mostrador.getVendedores(); }
    public int getEmpleadosEnSalaDescanso() throws RemoteException { return salaDescanso.getTotalEmpleados(); }

    public int getCafeEnDespensa() throws RemoteException { return despensa.getStockCafe(); }
    public int getRosquillasEnDespensa() throws RemoteException { return despensa.getDtockRosquillas(); }
    public int getCafeEnMostrador() throws RemoteException { return mostrador.getCafe(); }
    public int getRosquillasEnMostrador() throws RemoteException { return mostrador.getRosquillas(); }

    public double getRecaudacionActual() throws RemoteException { return caja.getDineroTotal(); }

    // MAIN
    public static void main(String[] args) {
        try {
            // 1. Instanciar el Servidor (crea monitores y GUI)
            ServidorCafeteria servidor = new ServidorCafeteria();
            
            // 2. Arrancar registro RMI
            LocateRegistry.createRegistry(1099);
            
            // 3. Publicar el objeto remoto
            Naming.rebind("//localhost/CafeteriaService", servidor);
            System.out.println("Servidor RMI registrado como '//localhost/CafeteriaService'");

            // 4. Iniciar la simulación
            servidor.iniciarSimulacion();

        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, "Error fatal en servidor: " + e.getMessage());
            System.exit(1);
        }
    }  
}