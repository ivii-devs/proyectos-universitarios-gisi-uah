#ifndef PILA_H
#define PILA_H

#include "NodoPila.h"
#include "Documento.h"
#include <iostream>

class Pila
{
    public:
        Pila();
        ~Pila();

        bool esVaciaPila();
        void apilar(Documento doc);
        void apilarTiempo(Documento doc);
        void desapilar();
        void borrarPila();
        int mostrarPilaCima();
        void mostrarPila();
        Documento mostrarDocumentoCima();
        int getLongitud();

    protected:

    private:
        pnodo cima; //Puntero al nodo de la cima de la pila
        int longitud;
};

#endif // PILA_H

