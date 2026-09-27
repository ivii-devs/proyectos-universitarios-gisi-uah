#include "NodoLista.h"

NodoLista::NodoLista(Impresora impre, NodoLista *sig)
{
    impresora = impre;
    siguiente = sig;
}

NodoLista::~NodoLista()
{
    //dtor
}
