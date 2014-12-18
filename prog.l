/*******************************************************************
* María Mercedes Alba Moyano, Granada (2014).
*
* JavaRb
*
* Traductor de ficheros escritos en Java a ficheros escritos en Ruby. 
* El fichero de salida tiene el mismo nombre que el de entrada, pero 
* cambiando la extensión de este adecuadamente.
* Para que salga un fichero Ruby funcional, el fichero de entrada 
* tiene que ser funcional en Java y si tiene funcionalidades que
* no están especificadas en el pdf adjunto no se reconoceran, o
* no se asegura un funcionamiento adecuado del traductor.
* 
*
* Licencia GPL_v3
********************************************************************/

/*---------------- Seccion de Declaraciones --------------*/
%option noyywrap
%{
#include <stdio.h>
#include <string.h>
char *nclase;
int private=0,protected=0,statico=0, clase=0,tab=0,metodo=0, t_s=0,defif=0,princ=0;
void defClase(char *nclase);
void defAtrib(char *nombre);
void defMetodo(char *nombre);
void defAtribMetodos(char *nombre);
void defIgualdad(char *nombre);
void final();
void defLlamada(char *nombre);
void defModule(char *nombre);
void defReturn(char *nombre);
void defConstr(char *nombre);
void defImp(char *nombre);
void defIncrem(char *nombre);
void defInstruccion(char *nombre);
void defEntrada(char *nombre);
void defComen(char *nombre);
void defComenLineas(char *nombre);
void defIf(char *nombre);
void defElse(char *nombre);
%}

palAcepta		[a-zA-Z][a-zA-Z0-9\_\-]*
modulo			"package ".*";"	
clase			"class "[^"{"]*
atributo		["String""int"{palAcepta}]" "{palAcepta}" "?";"
igualdad		"this."?{palAcepta}\40?=\40?({palAcepta}|\-?[0-9]*\.?[0-9]*|\".*\")" "?";"
atriIni			["String""int"{palAcepta}]" "{igualdad}
iniMetodo		{palAcepta}\40{palAcepta}"("({palAcepta}\40{palAcepta},\40?)*({palAcepta}\40{palAcepta}\40?)?")"[\40\n]*[\t\40]*"{"

llamada			("this."|({palAcepta}\.))?{palAcepta}"("\40?({palAcepta},\40?)*(\40?{palAcepta}\40?)?")"\40?";"
valordev		"return".*";"
strings			"String toString(){"
constructor		{palAcepta}\40?"="\40?"new ".*";"
impriVar		"System.out.print""ln"?"("[^ \"]*")"\40?";"
impriString		"System.out.print""ln"?"(".*\".*
main 			"public static void main"\40?"("\40?"String"?\40?"["?\40?"]"?\40?{palAcepta}?\40?")"
incremento		{palAcepta}\40?("++"|"--")\40?";"
instruccion		{palAcepta}"=".*";"
entrada			{palAcepta}\40?"="\40?{palAcepta}(".nextLine()"|".next()"|".nextInt()")\40?";"
scanner			.*"Scanner".*";"
detif			"if"\40?"(".*")"[\40\n]*"{"?
detelse			"else"\40?"{"?
%x comentario 


 /*------------- Seccion de Reglas -------------*/
 
%%

"/*"         {printf("=begin");BEGIN(comentario);}

<comentario>[^"*"\n]*		printf("%s",yytext);
<comentario>"*"+[^"*/"\n]*	printf("%s",yytext);
<comentario>\n				printf("\n");
<comentario>"*"+"/"       {printf("=end\n");BEGIN(0);}

{detif}			{defIf(yytext); defif++;}
{detelse}		{defElse(yytext); defif++;}


"//".*			{defComen(yytext);}
{entrada}		{defEntrada(yytext);}
{valordev}		{defReturn(yytext);}
{constructor}	{defConstr(yytext);}
{modulo}		{defModule(yytext);}
{clase} 		{defClase(yytext);}
private			{private=1;}
protegido		{protected=1;}
"static"		{statico=1;}
{strings}		{defMetodo("String to_s(){");t_s=1;}
{atributo}		{defAtrib(yytext);}
{atriIni}		{defAtrib(yytext);}
{iniMetodo}		{defMetodo(yytext);}
{igualdad}		{defIgualdad(yytext);}
{llamada}		{defLlamada(yytext);}
{impriString}	{t_s=1; defImp(yytext);}
{incremento}	{defIncrem(yytext);}
"}"				{final();}
{instruccion} 	{defInstruccion(yytext);}
{impriVar}		{defImp(yytext);}
{main}			{statico=0;princ=1;metodo++;}
{scanner}		{}
		

.|\n			{}

%%
/*------------- Seccion de Procedimientos -------------*/
int main(int argc,char *argv[]){
	
	if(argc==1){
		printf("¡No has introducido el nombre del fichero que quieres traducir! Así...¿Qué quieres que haga?\n");
		exit(-1);
	}
	else{
	
		int j=0,i;
		i=strlen(argv[1])-1;
		if(i>5){
			if(argv[1][i]=='a' && argv[1][i-1]=='v' && argv[1][i-2]=='a' && argv[1][i-3]=='j' && argv[1][i-4]=='.')
				j=1;
		}
		if(j==0){
			printf("%s no me gusta. Con ficheros que no sean .java no trabajo\n",argv[1]);
			exit(-1);
		}
		yyin=fopen(argv[1],"rt");
		if(yyin==NULL){
			printf("El fichero %s no se puede abrir\n",argv[1]);
			exit(-1);
		}
	}
	
	char *nombreFichero=(char*)malloc(strlen(argv[1])-2);
	int i=0;
	for(;i<strlen(argv[1]) && argv[1][i-1]!='.';i++){
		nombreFichero[i]=argv[1][i];
	}
	nombreFichero[i]='r'; i++;
	nombreFichero[i]='b';
	FILE *salida;
	salida=freopen( nombreFichero, "w", stdout );
	if(!salida) {
       printf("El fichero %s no puede ser creado.\n", argv[2]);
       fclose(yyin);
       return 1;
    }

	yylex();
	
	while(clase>0){
		tab--; 
		clase--; 
		for(i=0;i<tab;i++)
			printf("    "); 
		printf("end\n");
		}
	fclose(yyin);
	fclose(salida);
	return 0;
}

	/***************Escribe clase en Ruby******************/
void defClase(char *nombre){
	printf();
	clase++;
	char *aux=(char*)malloc(strlen(nombre)-5);
	int n=0, esp=0,i;
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	for(i=0; i<strlen(nombre); i++){
		if(nombre[i]==' '){
			if(esp==0)
				esp=1;
			else
				esp=0;
					
		}
		else{
			if(esp==1 && nombre[i]!='{'){
				aux[n]=nombre[i];
				n++;
			}
		}
	}
	nclase=aux;
	if(private==1)
		printf("private\n");
	if(protected==1)
		printf("protected\n");
	printf("class %s\n",aux);
	private=protected=0;
	tab++;
}
	/***************Escribe atributo******************/
void defAtrib(char *nombre){
	int n=0, esp=0,i;
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	for(i=0;i<strlen(nombre) && nombre[i]!=' '; i++){}
	i++;
	char *aux=(char*)malloc(strlen(nombre)-i);
	for(;i<strlen(nombre); i++){
		if(nombre[i]!=';'){	
			aux[n]=nombre[i];
			n++;
		}
	}
	if(statico==1)
		printf("@");
	printf("@%s\n",aux);
	statico=0;
}

	/***************Escribe metodo******************/
void defMetodo(char *nombre){
	int n=0, esp=0,i;
	metodo++;
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	for(i=0;i<strlen(nombre) && nombre[i]!=' '; i++){}
	i++;
	char *aux=(char*)malloc(strlen(nombre)-i);
	for(;i<strlen(nombre) && nombre[i]!='('; i++){
			aux[n]=nombre[i];
			n++;
	}
	int j;
	int constructor=1;
	for(j=0;j<strlen(aux) && constructor==1;j++){
		if(aux[j]!=nclase[j])
			constructor=0;
	}
	if(constructor==1)
		printf("def initialize");
	else
		printf("def %s",aux);
	
	defAtribMetodos(nombre+i+1);
	printf("\n");
	tab++;
	
}

	/**********Escribe los atributos del metodo**********/
void defAtribMetodos(char *nombre){
	int n=0,esp=0,i;
	char *aux=(char*)malloc(strlen(nombre));
	for(i=0;i<strlen(nombre) && nombre[i]!=')'; i++){
		if(nombre[i]==' '){
			esp=1;
		}
		else{
			if(esp==1){
				if( nombre[i]!=','){
					aux[n]=nombre[i];
					n++;
				}
				else{
					esp=0;
					if(nombre[i+1]==' '){
						aux[n]=',';
						i++;
						n++;
						aux[n]=' ';
						n++;
					}
				}
			}
		}
	}
	if(strlen(aux)!=0)
		printf("(%s)",aux);
	
}
	/**********Escribe una igualdad**********/
void defIgualdad(char *nombre){
	int i,n=0;
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	char *aux=(char*)malloc(strlen(nombre));
	for(i=0; i<strlen(nombre); i++){
		if(nombre[i]=='t' && nombre[i+1]=='h' && nombre[i+2]=='i' && nombre[i+3]=='s'){
			nombre[i]='s';
			nombre[i+1]='e';
			nombre[i+2]='l';
			nombre[i+3]='f';
		}
		if(nombre[i]!=' ' && nombre[i]!=';'){
			aux[n]=nombre[i];
			n++;
		}
	}
	
	printf("%s\n",aux);



}

void final(){
	int i;

	if(defif>0){
		defif--;
		tab--;

	}
	else if(metodo>0){
		metodo--;
		if(princ==1){
			princ++;
		}
		else{
			tab--;
		}
	}
	else if(clase>0){
		clase--;
		tab--;
	}
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	if(princ!=2){
		printf("end\n");
	}
	else princ=0;

}
	/************Escribe la llamada a una función**************/
void defLlamada(char *nombre){
	int n=0, esp=0,i;	
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	
	char *aux=(char*)malloc(strlen(nombre));
	for(i=0;i<strlen(nombre) && nombre[i]!='('; i++){
		if(nombre[i]=='t' && nombre[i+1]=='h' && nombre[i+2]=='i' && nombre[i+3]=='s'){
			nombre[i]='s';
			nombre[i+1]='e';
			nombre[i+2]='l';
			nombre[i+3]='f';
		}
		aux[n]=nombre[i];
		n++;
	}
	printf("%s",aux);
	n=0;
	i++;
	free(aux);
	aux=(char*)malloc(strlen(nombre)-i);
	for(;i<strlen(nombre) && nombre[i]!=')'; i++){
		aux[n]=nombre[i];
		n++;
	}
	if(strlen(aux)!=0)
		printf("(%s)",aux);
	printf("\n");
}

	/************Escribe module**************/
void defModule(char *nombre){
	int i,n=0;
	clase++;
	printf("Ckaseaumentada en modulo\n");
	if(tab>0){
		for(i=0; i<tab; i++)
			printf("    ");
	}
	for(i=0; i<strlen(nombre) && nombre[i]!=' '; i++){}
	i++;
	char *aux=(char*)malloc(strlen(nombre)-i);

	for(;i<strlen(nombre); i++){
		if(nombre[i]!=';'){
			aux[n]=nombre[i];	
			n++;
		}
	}
	
	printf("module %s\n",aux);
	
	tab++;
	
}
	/************Escribe return *************/
void defReturn(char *nombre){
	int i,n=0,esp=0,com=0,y=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	
	for(i=0;i<strlen(nombre) && nombre[i]!=' ';i++){}
	i++;
	char *aux=(char*)malloc(strlen(nombre)-i);
	if(t_s==0){
		for(;i<strlen(nombre); i++){
			if(nombre[i]=='t' && nombre[i+1]=='h' && nombre[i+2]=='i' && nombre[i+3]=='s'){
				nombre[i]='s';
				nombre[i+1]='e';
				nombre[i+2]='l';
				nombre[i+3]='f';
			}
			if(nombre[i]=='(' && nombre[i+1]==')'){
				i=i+1;
			}
			else if(nombre[i]!=';'){
				aux[n]=nombre[i];	
				n++;
			}
		
		}
	}
	else{
		aux[n]='"';
		n++;
		for(;i<strlen(nombre); i++){
			if(nombre[i]=='"'){
				com++;
				com=com%2;
			}
			else if(com==1){
					aux[n]=nombre[i];	
					n++;
				}
			else if(nombre[i]=='(' && nombre[i+1]==')'){
				i=i+1;
			}		
			else if(nombre[i]!='+' && nombre[i]!=' ' && nombre[i]!=';'){
				
				if(y==0){
					aux[n]='#';
					aux[n+1]='{';
					n=n+2;
					esp=0;
					y=1;
				}
				aux[n]=nombre[i];
				n++;
			}
			else if(y==1){
				y=0;
				aux[n]='}';
				n++;
				esp=0;
			}
		}
		aux[n]='"';
		t_s=0;
	}
	printf("%s\n",aux);

}

	/**********Escribir constructor new****************/
void defConstr(char *nombre){
	int i,n=0,j=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	
	for(i=0;i<strlen(nombre);i++){
		if(nombre[i]=='=' && j==0){
			i=9999999;
		}
		else{
			if(nombre[i]==' '){
				if(nombre[i+1]!='=')
					j=i;
				else
					i=9999999;
			}
		}	
	}
	i=j;
	char *aux=(char*)malloc(strlen(nombre)-i);
	for(;i<strlen(nombre) && nombre[i]!=')';i++){
		if(nombre[i]=='n' && nombre[i+1]=='e' && nombre[i+2]=='w'){
			i=i+4;
		}
		aux[n]=nombre[i];
		n++;
		if(nombre[i+1]=='('){
			aux[n]='.';
			aux[n+1]='n';
			aux[n+2]='e';
			aux[n+3]='w';
			n=n+4;
		}
	}
	aux[n]=')';
	
	printf("%s\n",aux);

}


	/************Imprimir******************/
void defImp(char *nombre){
	int i,n=0,esp=0,com=0,y=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	for(i=0; i<strlen(nombre) && nombre[i]!='(';i++){}
	char *aux=(char*)malloc(strlen(nombre));

	i++;
	aux[n]='p';n++;
	aux[n]='u';n++;
	aux[n]='t';n++;
	aux[n]='s';n++;
	aux[n]=' ';n++;
	
	
	if(t_s==0){
		for(;i<strlen(nombre) && nombre[i]!=')'; i++){
			if(nombre[i]=='(' && nombre[i+1]==')'){
				i=i+1;
			}			
			else if(nombre[i]!=';'){
				aux[n]=nombre[i];	
				n++;
			}
		
		}
	}
	else{
		aux[n]='"';
		n++;
		for(;i<strlen(nombre) && nombre[i]!=')'; i++){
			
			if(nombre[i]=='"'){
				com++;
				com=com%2;
			}
			else if(com==1){
					aux[n]=nombre[i];	
					n++;
				}
			else if(nombre[i]=='(' && nombre[i+1]==')'){
				i=i+1;
			}		
			else if(nombre[i]!='+' && nombre[i]!=' ' && nombre[i]!=';'){
				
				if(y==0){
					aux[n]='#';
					aux[n+1]='{';
					n=n+2;
					esp=0;
					y=1;
				}
				aux[n]=nombre[i];
				n++;
			}
			else if(y==1){
				y=0;
				aux[n]='}';
				n++;
				esp=0;
			}
		}
		if(y==1){
			aux[n]='}';
			n++;
		}
		aux[n]='"';
		t_s=0;
	}
	printf("%s\n",aux);
	
}

void defIncrem(char *nombre){
	int i,n=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	
	char *aux=(char*)malloc(strlen(nombre)+1);
	for(i=0; i<strlen(nombre) && nombre[i]!='+' && nombre[i]!='-' ; i++){
		aux[n]=nombre[i];
		n++;
	}

	aux[n]=nombre[i];
	n++;
	aux[n]='=';
	n++;
	aux[n]='1';
	printf("%s\n",aux);
}

void defInstruccion(char *nombre){
	int i,n=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	char *aux=(char*)malloc(strlen(nombre));
	
	for(i=0; i<strlen(nombre) && nombre[i]!=';';i++){
		if(nombre[i]=='t' && nombre[i+1]=='h' && nombre[i+2]=='i' && nombre[i+3]=='s'){
			nombre[i]='s';
			nombre[i+1]='e';
			nombre[i+2]='l';
			nombre[i+3]='f';
		}
		if(nombre[i]=='(' && nombre[i+1]==')' ){
			n=n+2;
		}
		
		aux[n]=nombre[i];
		n++;
	
	}
	printf("%s\n",aux);


}


void defEntrada(char *nombre){
	int i,igual=0;
	
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	printf("STDOUT.flush\n");
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	char *aux=(char*)malloc(strlen(nombre));
	for(i=0;i<strlen(nombre) && igual!=1; i++){
		aux[i]=nombre[i];
		if(nombre[i]=='=')
			igual=1;
	}
	printf("%sgets.chomp\n",aux);

}


void defComen(char *nombre){
	int i=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	char *aux=(char*)malloc(strlen(nombre));
	printf("#");
	for(i=2; i<strlen(nombre); i++){
		aux[i-2]=nombre[i];
		
	}
	printf("%s\n",aux);

}
void defComenLineas(char *nombre){
	int i=0,n=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	char *aux=(char*)malloc(strlen(nombre));
	printf("=begin");
	for(i=2; i<strlen(nombre); i++){
		if(nombre[i]!='*'){
			aux[n]=nombre[i];
			n++;
		}
	}
	printf("%s",aux);
	printf("=end\n");

}

void defIf(char *nombre){
	int i=0,n=0;
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	char *aux=(char *)malloc(strlen(nombre));
	for(; i<strlen(nombre); i++){
		if(nombre[i]=='(' || nombre[i]==')' || nombre[i]=='{'){
			aux[n]=' ';
			
		}
		else{
			aux[n]=nombre[i];

		}
		n++;
	}
	tab++;
	printf("if%s\n",aux);
}

void defElse(char *nombre){
	int i=0,n=0;
	
	if(tab>0){
		for(i=0;i<tab;i++)
			printf("    ");
	}
	
	tab++;
	printf("else\n");


}
