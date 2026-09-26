#ifndef SISTEMA_H
#define SISTEMA_H

#include "Pila.h"
#include "Cola.h"
#include "Impresora.h"
#include "Documento.h"
#include "Lista.h"
#include "ABB.h"
#include <iostream>

class Sistema
{
    public:
        Sistema();
        ~Sistema();

        //Crea documentos manualmente
        void crearDocumento();

        //Muestra la pila de documentos
        void mostrarPilaDocumentos();

        //Borra la pila de documentos
        void borrarPilaDocumentos();

        //Muestra la impresora
        void mostrarEstadoImpresoras();

        int getTiempoActual();

        //Simulacion de tiempo
        void simularUnMinuto();
        void simularTiempo(int minutos);
        void simularTodo();

        bool hayImpresorasOcupadas();
        void eliminarImpresorasLibres();
        Impresora obtenerImpersoraMenosOcupada();
        Impresora obtenerImpersoraMasOcupada();
        int obtenerNumImpresorasFuncionando();
        void agregarDocumentoImpresoraMenosOcupada(Documento doc);

        //ABB
        void mostrarABB();
        void mostrarDocsDepto(string depto);
        void mostrarDeptos();
        void insertarDocEnABB();
        void calcularTiempoImpresionDepto(string depto);
        void calcularTiempoImpresionGeneral();
        void deptoMasMenosUsado();

    protected:

    private:
        Pila pila; //Pila donde se almacenan los documentos según la hora de llegada
        Lista listaImpresoras;
        ABB arbolDepartamentos;
        int tiempoActual;
        int totalDocumentos;
        int tiempoTotalSistema;
        double tiempoMedioImpresion;
};

#endif // SISTEMA_H
