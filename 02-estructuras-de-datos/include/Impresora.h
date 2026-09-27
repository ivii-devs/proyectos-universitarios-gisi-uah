#ifndef IMPRESORA_H
#define IMPRESORA_H

#include <iostream>
#include "Documento.h"
#include "Cola.h"

using namespace std;

class Impresora
{
    public:
        Impresora();
        Impresora(int idImpresora);
        virtual ~Impresora();

        //Asignar un documento
        void asignarDocumento(Documento doc);

        //Actualizar impresora (reducir el tiempo)
        bool actualizar(int tiempo);

        //Liberar la impresora cuando termina de imprimir
        void liberar();

        //Comprobar si la impresora esta libre u ocupada
        bool estaLibre();

        //Mostrar el estado de la impresora
        void mostrarEstado();

        //Obtener el id de la impresora
        int getIdImpresora();

        //Obtener el tiempo de impresion restante de la impresora
        int getTiempoRestante();

        //Obtener el documento actual que se esta imprimiendo
        Documento getDocumentoActual();

        //Agrega un documento a la cola de espera
        void agregarDocumentoCola(Documento doc);

        //Muestra los documentos de la cola de la impresora
        void mostrarColaDocumentos();

        //Verifica si hay documentos en la cola
        bool hayDocumentosEnCola();

        //Devuelve la COLA por referencia para evitar copias y destrucciones prematuras
        Cola& getColaDocumentos();

        //Set el tiempo restante
        void setTiempoRestanteReset();

        //Set la impresora a ocupada
        void setOcupadaReset();

    protected:

    private:
        int idImpresora;
        Documento documentoActual;
        int tiempoRestante;
        bool ocupada;
        Cola colaDocumentos;
};

#endif // IMPRESORA_H
