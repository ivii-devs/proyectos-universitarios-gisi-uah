package poo.peclcafeteria;

import java.rmi.Remote;
import java.rmi.RemoteException;

/**
 * Interfaz remota que define los métodos disponibles para el cliente RMI
 * Permite consultar el estado de la cafeteria y controlar la simulacion
 */
public interface InterfazMonitorCafeteria extends Remote {

    // Control de la Simulación 
    void pausar() throws RemoteException;
    void reanudar() throws RemoteException;
    
    // Para sincronizar el boton cliente
    boolean estaPausado() throws RemoteException;

    // Consultas de Aforo (Clientes) 
    int getClientesEnParque() throws RemoteException;
    int getClientesEnMostrador() throws RemoteException;
    int getClientesEnCaja() throws RemoteException;
    int getClientesEnAreaConsumicion() throws RemoteException;
    
    // Consultas de Aforo (Empleados) 
    int getCocinerosEnCocina() throws RemoteException;
    int getCocinerosEnDespensa() throws RemoteException;
    int getVendedoresEnDespensa() throws RemoteException;
    int getVendedoresEnMostrador() throws RemoteException;
    int getEmpleadosEnSalaDescanso() throws RemoteException;

    // Consultas de Inventario de Cafe y Rosquillas
    int getCafeEnDespensa() throws RemoteException;
    int getRosquillasEnDespensa() throws RemoteException;
    int getCafeEnMostrador() throws RemoteException;
    int getRosquillasEnMostrador() throws RemoteException;

    // Recaudación
    double getRecaudacionActual() throws RemoteException;
}