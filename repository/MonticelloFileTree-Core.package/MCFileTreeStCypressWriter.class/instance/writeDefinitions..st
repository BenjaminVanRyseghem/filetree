initialize-release
writeDefinitions: aCollection
  | classDirExtension extensionClasses extensionMethodDefinitions extensionMethodMap methodHolders |
  self writeBasicDefinitions: aCollection.
  extensionClasses := OrderedCollection new.
  extensionMethodDefinitions := OrderedCollection new.
  methodHolders := self classDefinitions.
  self methodDefinitions
    keysAndValuesDo: [ :className :extensionMethods | 
      methodHolders
        at: className
        ifAbsent: [ 
          extensionClasses add: className.
          extensionMethodDefinitions addAll: extensionMethods ] ].
  extensionClasses
    do: [ :className | self methodDefinitions removeKey: className ].
  self
    writeMethodHolderDefinitions: self classDefinitions
    extension: '.class'
    to: ''
    do: [ :definition :classPath | self writeClassDefinition: definition to: classPath ].
  classDirExtension := '.extension'.
  extensionMethodMap := Dictionary new.
  extensionMethodDefinitions
    do: [ :methodDefinition | 
      | classPath methodPath |
      (extensionMethodMap
        at: methodDefinition className
        ifAbsent: [ extensionMethodMap at: methodDefinition className put: OrderedCollection new ])
        add: methodDefinition.
      classPath := methodDefinition className , classDirExtension
        , self fileUtils pathNameDelimiter asString.
      self writeExtensionClassDefinition: methodDefinition to: classPath ].
  extensionMethodMap
    keysAndValuesDo: [ :className :classMethodDefinitions | 
      | classPath filenameMetaMap |
      filenameMetaMap := self fileNameMapFor: classMethodDefinitions.
      classMethodDefinitions
        do: [ :methodDefinition | 
          | filename methodPath |
          filename := (filenameMetaMap at: methodDefinition classIsMeta)
            at: methodDefinition selector.
          classPath := methodDefinition className , classDirExtension
            , self fileUtils pathNameDelimiter asString.
          methodPath := classPath
            ,
              (methodDefinition classIsMeta
                ifTrue: [ 'class' ]
                ifFalse: [ 'instance' ])
            , self fileUtils pathNameDelimiter asString.
          self
            writeMethodDefinition: methodDefinition
            to: methodPath
            filename: filename ].
      classPath := className , classDirExtension
        , self fileUtils pathNameDelimiter asString.
      self
        writeInDirectoryName: classPath
        fileName: 'methodProperties'
        extension: self propertyFileExtension
        visit: [ self writeMethodProperties: classMethodDefinitions ] ]