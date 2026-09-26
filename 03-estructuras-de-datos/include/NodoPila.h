#ifndef NODOPILA_H
#define NODOPILA_H

#include "Documento.h"
#include <iostream>

class NodoPila
{
    public:
        NodoPila();
        NodoPila(Documento doc, NodoPila *sig = NULL);
        ~NodoPila();

    protected:

    private:
        Documento documento;
        NodoPila *siguiente; //Puntero al siguiente nodo
        friend class Pila; //Para que la clase Pila tenga acceso a los atributos privados
};

typedef NodoPila *pnodo; //Tipo para los punteros a NodoPila

#endif // NODOPILA_H

