#ifndef NODOLISTA_H
#define NODOLISTA_H

#include "Impresora.h"
#include <iostream>

class NodoLista
{
    public:
        NodoLista();
        NodoLista(Impresora impre, NodoLista *sig = NULL);
        ~NodoLista();

    protected:

    private:
        Impresora impresora; //Impresora
        NodoLista* siguiente; //Puntero al siguiente nodo
        friend class Lista;
};

#endif // NODOLISTA_H
