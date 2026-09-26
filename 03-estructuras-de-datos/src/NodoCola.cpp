#include "NodoCola.h"

NodoCola::NodoCola()
{
    //constructor por defecto
    //documento = '0';
    //siguiente = NULL;
}

NodoCola::NodoCola(Documento doc, NodoCola *sig)
{
    documento = doc;
    siguiente = sig;
}

NodoCola::~NodoCola()
{
    //dtor
}
