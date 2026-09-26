#include "NodoListaDocs.h"

NodoListaDocs::NodoListaDocs(Documento doc, NodoListaDocs *sig)
{
    documento = doc;
    siguiente = sig;
}

NodoListaDocs::~NodoListaDocs()
{
    //dtor
}
