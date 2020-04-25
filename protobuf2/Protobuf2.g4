grammar Protobuf2;
// Lexical elements;

// Letters and digits;

fragment Letter : [A-Za-z_];
fragment CapitalLetter : [A-Z];
fragment DecimalDigit : [0-9];
fragment OctalDigit   : [0-7];
fragment HexDigit     : [0-9A-Fa-f];

Ident : Letter (Letter | DecimalDigit)*;
fullIdent : Ident ('.' Ident)*;
messageName : Ident;
enumName : Ident;
fieldName : Ident;
oneofName : Ident;
mapName : Ident;
serviceName : Ident;
rpcName : Ident;
streamName : Ident;
messageType : '.'? (Ident '.')* messageName;
enumType : '.'? (Ident '.') enumName;
groupName : CapitalLetter (Letter | DecimalDigit);

// Integer literals;

IntLit     : DecimalLit | OctalLit | HexLit;
fragment DecimalLit : [1-9] DecimalDigit*;
fragment OctalLit   : '0' OctalDigit*;
fragment HexLit     : '0' ( 'x' | 'X' ) HexDigit+;

// Floating-point literals;

FloatLit : ( Decimals '.' Decimals? Exponent? | Decimals Exponent | '.' Decimals Exponent? ) | 'inf' | 'nan';
fragment Decimals  : DecimalDigit+;
fragment Exponent  : ( 'e' | 'E' ) ( '+' | '-' )? Decimals;
// Boolean;

BoolLit : 'true' | 'false';
// String literals;

StrLit : ( '\'' CharValue* '\'' ) | ( '"' CharValue* '"' );
fragment CharValue
    : HexEscape
    | OctEscape
    | CharEscape
    | ~[\u0000\n\\]
    ;
fragment HexEscape : '\\' ( 'x' | 'X' ) HexDigit HexDigit;
fragment OctEscape : '\\' OctalDigit OctalDigit OctalDigit;
fragment CharEscape : '\\' ( 'a' | 'b' | 'f' | 'n' | 'r' | 't' | 'v' | '\\' | '\'' | '"' );
Quote : '\'' | '"';

// EmptyStatement;

emptyStatement : ';';

// Constant;

constant : fullIdent | ( ('-' | '+')? IntLit ) | ( ('-' | '+')? FloatLit ) | (StrLit | BoolLit);
// Syntax;

// The syntax statement is used to define the protobuf version.;

syntax :  'syntax' '=' ('"proto2"' | '\'proto2\'' ) ';';

// Import Statement;

// The import statement is used to import another .proto's definitions.;

importStmt : 'import' ('weak' | 'public')? StrLit ';';

// Package;

// The package specifier can be used to prevent name clashes between protocol message types.;

packageStmt : 'package' fullIdent ';';

// Option;

// Options can be used in proto files, messages, enums and services. An option can be a protobuf defined option or a custom option. For more information, see Options in the language guide.;

option : 'option' optionName '=' constant ';';
optionName : ( Ident | '(' fullIdent ')' ) ('.' Ident)*;

// Fields;

// Fields are the basic elements of a protocol buffer message. Fields can be normal fields, group fields, oneof fields, or map fields. A field has a label, type and field number.;

label : 'required' | 'optional' | 'repeated';
type : 'double' | 'float' | 'int32' | 'int64' | 'uint32' | 'uint64'
      | 'sint32' | 'sint64' | 'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64'
      | 'bool' | 'string' | 'bytes' | messageType | enumType;
fieldNumber : IntLit;

// Normal field;

// Each field has label, type, name and field number. It may have field options.;

field : label type fieldName '=' fieldNumber ('[' fieldOptions ']')? ';';
fieldOptions : fieldOption (','  fieldOption);
fieldOption : optionName '=' constant;

// Group field;

// Groups are one way to nest information in message definitions. The group name must begin with capital Letter.;

group : label 'group' groupName '=' fieldNumber messageBody;

// Oneof and oneof field;

// A oneof consists of oneof fields and a oneof name. Oneof fields do not have labels.;

oneof : 'oneof' oneofName '{' (oneofField | emptyStatement) '}';
oneofField : type fieldName '=' fieldNumber  ('[' fieldOptions ']')? ';';


// Map field;
// A map field has a key type, value type, name, and field number. The key type can be any integral or string type.;

mapField : 'map' '<' keyType ',' type '>' mapName '=' fieldNumber ('[' fieldOptions ']')? ';';
keyType : 'int32' | 'int64' | 'uint32' | 'uint64' | 'sint32' | 'sint64' |
          'fixed32' | 'fixed64' | 'sfixed32' | 'sfixed64' | 'bool' | 'string';

//Extensions and Reserved;
//Extensions and reserved are message elements that declare a range of field numbers or field names.;
//
//Extensions;
//Extensions declare that a range of field numbers in a message are available for third-party extensions. Other people can declare new fields for your message type with those numeric tags in their own .proto files without having to edit the original file.;

extensions : 'extensions' ranges ';';
ranges : range (',' range);
range :  IntLit ('to' ( IntLit | 'max' ))?;

//Reserved;
//Reserved declares a range of field numbers or field names in a message that can not be used.;

reserved : 'reserved' ( ranges | fieldNames ) ';';
fieldNames : fieldName (',' fieldName);

//Top Level definitions;
//
//enumDef definition;
//
//The enumDef definition consists of a name and an enumDef body. The enumDef body can have options and enumDef fields.;

enumDef : 'enumDef' enumName enumBody;
enumBody : '{' (option | enumField | emptyStatement) '}';
enumField : Ident '=' IntLit ('[' enumValueOption (','  enumValueOption) ']') ';';
enumValueOption : optionName '=' constant;

//Message definition;
//A message consists of a message name and a message body. The message body can have fields, nested enumDef definitions, nested message definitions, extend statements, extensions, groups, options, oneofs, map fields, and reserved statements.;

message : 'message' messageName messageBody;
messageBody : '{' (field | enumDef | message | extend | extensions | group |
option | oneof | mapField | reserved | emptyStatement)* '}';

//Extend;
//If a message in the same or imported .proto file has reserved a range for extensions, the message can be extended.;

extend : 'extend' messageType '{' (field | group | emptyStatement)* '}';

//Service definition;

service : 'service' serviceName '{' (option | rpc | stream | emptyStatement)* '}';
rpc : 'rpc' rpcName '(' 'stream'? messageType ')' 'returns' '(' 'stream'?
      messageType ')' (( '{' (option | emptyStatement)* '}' ) | ';' );

stream : 'stream' streamName '(' messageType ',' messageType ')' (( '{'
      (option | emptyStatement)* '}') | ';' );

//Proto file;

proto : syntax (importStmt | packageStmt | option | topLevelDef | emptyStatement)*;
topLevelDef : message | enumDef | extend | service;

// Separators

LPAREN          : '(';
RPAREN          : ')';
LBRACE          : '{';
RBRACE          : '}';
LBRACK          : '[';
RBRACK          : ']';
LCHEVR          : '<';
RCHEVR          : '>';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';
MINUS           : '-';
PLUS            : '+';

// Operators

ASSIGN          : '=';

// Whitespace and comments

WS  :   [ \t\r\n\u000C]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;
