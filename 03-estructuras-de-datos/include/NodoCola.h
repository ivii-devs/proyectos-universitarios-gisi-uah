#ifndef NODOCOLA_H
#define NODOCOLA_H

#include "Documento.h"
#include <iostream>

class NodoCola
{
    public:
        NodoCola();
        NodoCola(Documento doc, NodoCola *sig = NULL);
        ~NodoCola();

    protected:

    private:
        NodoCola *siguiente; //Puntero al siguiente nodo
        Documento documento;
        friend class Cola; //Para que la clase Pila tenga acceso a los atributos privados
};

#endif // NODOCOLA_H
