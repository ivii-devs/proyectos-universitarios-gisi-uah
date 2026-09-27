#include "NodoPila.h"

NodoPila::NodoPila()
{
    //constructor por defecto
    //documento = ;
    //siguiente = NULL;
}

NodoPila::NodoPila(Documento doc, NodoPila *sig)
{
    documento = doc;
    siguiente = sig;
}

NodoPila::~NodoPila()
{
    //dtor
}
