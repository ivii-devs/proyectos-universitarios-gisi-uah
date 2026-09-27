package poo.peclcafeteria;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.rmi.Naming;
import java.text.DecimalFormat;

/**
 * CLIENTE RMI
 * Muestra el estado de la cafetería en tiempo real conectándose al servidor remoto.
 * Se actualiza automáticamente cada 1 segundo.
 */
public class ClienteMonitor extends JFrame {

    // Referencia al objeto remoto
    private InterfazMonitorCafeteria servidor;
    
    // Componentes GUI 
    private JButton btnPausar;
    
    // Campos de texto para datos
    private JTextField txtParque;
    private JTextField txtMostradorClientes, txtMostradorVendedores;
    private JTextField txtMostradorCafe, txtMostradorRosquillas;
    private JTextField txtCaja;
    private JTextField txtAreaConsumicion;
    private JTextField txtCocina;
    private JTextField txtDespensaCocineros, txtDespensaVendedores;
    private JTextField txtDespensaCafe, txtDespensaRosquillas;
    private JTextField txtSalaDescanso;
    private JTextField txtRecaudacion;

    private DecimalFormat formatoDinero = new DecimalFormat("#,##0.00 €");

    public ClienteMonitor() {
        super("Simulación Cafetería - Cliente");
        configurarVentana();
        conectarServidor();
        iniciarActualizacionAutomatica();
    }

    private void configurarVentana() {
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(500, 700);
        setLocationRelativeTo(null);
        setLayout(new GridBagLayout()); // Layout flexible para organizar paneles

        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5); // Márgenes
        gbc.fill = GridBagConstraints.HORIZONTAL;
        gbc.weightx = 1.0;
        gbc.gridx = 0;

        // 1. BOTÓN SUPERIOR
        btnPausar = new JButton("REANUDAR SIMULACIÓN");
        btnPausar.setFont(new Font("Arial", Font.BOLD, 14));
        btnPausar.setBackground(new Color(180, 255, 180));
        btnPausar.addActionListener(e -> accionBotonPausa());
        gbc.gridy = 0;
        add(btnPausar, gbc);

        // 2. PARQUE
        JPanel panelParque = crearPanelBorde("Parque");
        txtParque = addCampo(panelParque, "Clientes:");
        gbc.gridy++;
        add(panelParque, gbc);

        // 3. MOSTRADOR
        JPanel panelMostrador = crearPanelBorde("Mostrador");
        panelMostrador.setLayout(new GridLayout(2, 2, 5, 5)); // Rejilla interna
        txtMostradorClientes = addEtiquetaYCampo(panelMostrador, "Clientes:");
        txtMostradorVendedores = addEtiquetaYCampo(panelMostrador, "Vendedores:");
        txtMostradorCafe = addEtiquetaYCampo(panelMostrador, "Cafés:");
        txtMostradorRosquillas = addEtiquetaYCampo(panelMostrador, "Rosquillas:");
        gbc.gridy++;
        add(panelMostrador, gbc);

        // 4. CAJA
        JPanel panelCaja = crearPanelBorde("Caja");
        txtCaja = addCampo(panelCaja, "Clientes en cola:");
        gbc.gridy++;
        add(panelCaja, gbc);

        // 5. ÁREA DE CONSUMICIÓN
        JPanel panelConsumo = crearPanelBorde("Área de Consumición");
        txtAreaConsumicion = addCampo(panelConsumo, "Clientes consumiendo:");
        gbc.gridy++;
        add(panelConsumo, gbc);

        // 6. COCINA
        JPanel panelCocina = crearPanelBorde("Cocina");
        txtCocina = addCampo(panelCocina, "Cocineros trabajando:");
        gbc.gridy++;
        add(panelCocina, gbc);

        // 7. DESPENSA
        JPanel panelDespensa = crearPanelBorde("Despensa");
        panelDespensa.setLayout(new GridLayout(2, 2, 5, 5));
        txtDespensaCocineros = addEtiquetaYCampo(panelDespensa, "Cocineros:");
        txtDespensaVendedores = addEtiquetaYCampo(panelDespensa, "Vendedores:");
        txtDespensaCafe = addEtiquetaYCampo(panelDespensa, "Cafés:");
        txtDespensaRosquillas = addEtiquetaYCampo(panelDespensa, "Rosquillas:");
        gbc.gridy++;
        add(panelDespensa, gbc);

        // 8. SALA DE DESCANSO
        JPanel panelDescanso = crearPanelBorde("Sala de Descanso");
        txtSalaDescanso = addCampo(panelDescanso, "Empleados totales:");
        gbc.gridy++;
        add(panelDescanso, gbc);

        // 9. RECAUDACIÓN
        JPanel panelRecaudacion = crearPanelBorde("Recaudación");
        txtRecaudacion = addCampo(panelRecaudacion, "Total:");
        txtRecaudacion.setFont(new Font("Arial", Font.BOLD, 14));
        txtRecaudacion.setForeground(new Color(0, 100, 0)); // Verde oscuro
        gbc.gridy++;
        add(panelRecaudacion, gbc);
    }

    // Métodos Auxiliares para GUI

    private JPanel crearPanelBorde(String titulo) {
        JPanel p = new JPanel(new FlowLayout(FlowLayout.LEFT));
        p.setBorder(BorderFactory.createTitledBorder(
                BorderFactory.createLineBorder(Color.GRAY), titulo, TitledBorder.LEFT, TitledBorder.TOP, new Font("Arial", Font.BOLD, 12)
        ));
        return p;
    }

    private JTextField addCampo(JPanel panel, String label) {
        panel.add(new JLabel(label));
        JTextField tf = new JTextField(8);
        tf.setEditable(false);
        tf.setHorizontalAlignment(JTextField.CENTER);
        panel.add(tf);
        return tf;
    }

    private JTextField addEtiquetaYCampo(JPanel panel, String label) {
        JPanel sub = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        sub.add(new JLabel(label));
        JTextField tf = new JTextField(5);
        tf.setEditable(false);
        tf.setHorizontalAlignment(JTextField.CENTER);
        sub.add(tf);
        panel.add(sub);
        return tf;
    }

    // Lógica RMI 

    private void conectarServidor() {
        try {
            // Buscamos el servicio en localhost (o IP del servidor) puerto 1099
            String url = "//localhost/CafeteriaService";
            servidor = (InterfazMonitorCafeteria) Naming.lookup(url);
            JOptionPane.showMessageDialog(this, "Conectado al servidor correctamente.", "Conexión RMI", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "No se pudo conectar al servidor:\n" + e.getMessage(), "Error de Conexión", JOptionPane.ERROR_MESSAGE);
            // e.printStackTrace();
        }
    }

    private void iniciarActualizacionAutomatica() {
        // Timer que se ejecuta cada 1000 ms (1 segundo)
        Timer timer = new Timer(1000, e -> actualizarDatos());
        timer.start();
    }

    private void actualizarDatos() {
        if (servidor == null) return;

        try {
            // Llamadas remotas para obtener datos
            txtParque.setText(String.valueOf(servidor.getClientesEnParque()));
            
            txtMostradorClientes.setText(String.valueOf(servidor.getClientesEnMostrador()));
            txtMostradorVendedores.setText(String.valueOf(servidor.getVendedoresEnMostrador()));
            txtMostradorCafe.setText(String.valueOf(servidor.getCafeEnMostrador()));
            txtMostradorRosquillas.setText(String.valueOf(servidor.getRosquillasEnMostrador()));

            txtCaja.setText(String.valueOf(servidor.getClientesEnCaja()));
            txtAreaConsumicion.setText(String.valueOf(servidor.getClientesEnAreaConsumicion()));
            txtCocina.setText(String.valueOf(servidor.getCocinerosEnCocina()));
            
            txtDespensaCocineros.setText(String.valueOf(servidor.getCocinerosEnDespensa()));
            txtDespensaVendedores.setText(String.valueOf(servidor.getVendedoresEnDespensa()));
            txtDespensaCafe.setText(String.valueOf(servidor.getCafeEnDespensa()));
            txtDespensaRosquillas.setText(String.valueOf(servidor.getRosquillasEnDespensa()));

            txtSalaDescanso.setText(String.valueOf(servidor.getEmpleadosEnSalaDescanso()));
            
            txtRecaudacion.setText(formatoDinero.format(servidor.getRecaudacionActual()));
            
            // sINCRO del boton
            boolean isServerPausado = servidor.estaPausado();
            
            if (isServerPausado) {
                btnPausar.setText("REANUDAR SIMULACIÓN");
                btnPausar.setBackground(new Color(180, 255, 180));
            } else {
                btnPausar.setText("PAUSAR SIMULACIÓN");
                btnPausar.setBackground(new Color(255, 180, 180));
            }

        } catch (Exception e) {
            System.err.println("Error al actualizar datos (Servidor caído?): " + e.getMessage());
            setTitle("Monitor Remoto - DESCONECTADO");
        }
    }

    private void accionBotonPausa() {
        if (servidor == null) return;

        try {
            if (servidor.estaPausado()) {
                servidor.reanudar();
            } else {
                servidor.pausar();
            }
            
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Error: " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        // Arrancar la GUI en el hilo de eventos de Swing
        SwingUtilities.invokeLater(() -> {
            new ClienteMonitor().setVisible(true);
        });
    }
}