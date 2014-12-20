unit FHIRIndexManagers;

{
Copyright (c) 2001-2013, Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}

interface

{
outstanding search issues:
* text searching

combinations to enable:
  name[family eq x and given eq y]


}
uses
  SysUtils, Classes, Generics.Collections,
  AdvObjects, AdvObjectLists, AdvNames, AdvXmlBuilders,
  EncodeSupport, DecimalSupport, HL7v2dateSupport, StringSupport, GuidSupport,
  KDBManager,
  FHIRBase, FhirSupport, FHIRResources, FHIRComponents, FHIRConstants, FHIRAtomFeed, FHIRTypes, FHIRTags, FHIRUtilities, FHIRParser,
  TerminologyServerStore,
  UcumServices;

Const
  INDEX_ENTRY_LENGTH = 128;
  NARRATIVE_INDEX_NAME = '_text';

Type
  TKeyType = (ktResource, ktEntries, ktCompartment);

  TFHIRGetNextKey = function (keytype : TKeyType) : Integer of Object;

  TFhirIndex = class (TAdvObject)
  private
    FResourceType : TFhirResourceType;
    FKey: Integer;
    FName: String;
    FDescription : String;
    FSearchType: TFhirSearchParamType;
    FTargetTypes : TFhirResourceTypeSet;
  public
    function Link : TFhirIndex; Overload;
    function Clone : TFhirIndex; Overload;
    procedure Assign(source : TAdvObject); Override;

    property ResourceType : TFhirResourceType read FResourceType write FResourceType;
    property Name : String read FName write FName;
    Property Description : String read FDescription write FDescription;
    Property Key : Integer read FKey write FKey;
    Property SearchType : TFhirSearchParamType read FSearchType write FSearchType;
    Property TargetTypes : TFhirResourceTypeSet read FTargetTypes write FTargetTypes;
  end;

  TFhirIndexList = class (TAdvObjectList)
  private
    function GetItemN(iIndex: integer): TFhirIndex;
  protected
    function ItemClass : TAdvObjectClass; override;
  public
    function Link : TFhirIndexList; Overload;

    function getByName(atype : TFhirResourceType; name : String): TFhirIndex;
    procedure add(aResourceType : TFhirResourceType; name, description : String; aType : TFhirSearchParamType; aTargetTypes : TFhirResourceTypeSet); overload;
    Property Item[iIndex : integer] : TFhirIndex read GetItemN; default;
  end;

  TFhirComposite = class (TAdvObject)
  private
    FResourceType : TFhirResourceType;
    FKey: Integer;
    FName: String;
    FComponents : TDictionary<String, String>;
  public
    Constructor Create; override;
    Destructor Destroy; override;

    function Link : TFhirComposite; Overload;
    function Clone : TFhirComposite; Overload;
    procedure Assign(source : TAdvObject); Override;

    property ResourceType : TFhirResourceType read FResourceType write FResourceType;
    property Name : String read FName write FName;
    Property Key : Integer read FKey write FKey;
    Property Components : TDictionary<String, String> read FComponents;
  end;

  TFhirCompositeList = class (TAdvObjectList)
  private
    function GetItemN(iIndex: integer): TFhirComposite;
  protected
    function ItemClass : TAdvObjectClass; override;
  public
    function Link : TFhirCompositeList; Overload;

    function getByName(atype : TFhirResourceType; name : String): TFhirComposite;
    procedure add(aResourceType : TFhirResourceType; name : String; components : array of String); overload;
    Property Item[iIndex : integer] : TFhirComposite read GetItemN; default;
  end;

  TFhirIndexEntry = class (TAdvObject)
  private
    FKey: integer;
    FEntryKey : integer;
    FIndexKey : integer;
    FValue1: String;
    FValue2: String;
    FRefType: integer;
    FTarget: integer;
    FConcept : integer;
    FType: TFhirSearchParamType;
    FParent: Integer;
    FFlag: boolean;
  public
    Property EntryKey : Integer Read FEntryKey write FEntryKey;
    Property IndexKey : Integer Read FIndexKey write FIndexKey;
    property Key : integer read FKey write FKey;
    Property Parent : Integer read FParent write FParent;
    property Value1 : String read FValue1 write FValue1;
    property Value2 : String read FValue2 write FValue2;
    property RefType : integer read FRefType write FRefType;
    Property target : integer read FTarget write FTarget;
    Property concept : integer read FConcept write FConcept;
    Property type_ : TFhirSearchParamType read FType write FType;
    Property flag : boolean read FFlag write FFlag;
  end;

  TFhirIndexEntryList = class (TAdvObjectList)
  private
    FKeyEvent : TFHIRGetNextKey;
    function GetItemN(iIndex: integer): TFhirIndexEntry;
  protected
    function ItemClass : TAdvObjectClass; override;
  public
    function add(key, parent : integer; index : TFhirIndex; ref : integer; value1, value2 : String; target : integer; type_ : TFhirSearchParamType; flag : boolean = false; concept : integer = 0) : integer; overload;
    function add(key, parent : integer; index : TFhirComposite) : integer; overload;
    Property Item[iIndexEntry : integer] : TFhirIndexEntry read GetItemN; default;
    property KeyEvent : TFHIRGetNextKey read FKeyEvent write FKeyEvent;
  end;

  TFhirCompartmentEntry = class (TAdvObject)
  private
    FCKey: integer;
    FKey: integer;
    FId: string;
  public
    property Key : integer read FKey write FKey;
    property CKey : integer read FCKey write FCKey;
    property Id : string read FId write FId;
  end;

  TFhirCompartmentEntryList = class (TAdvObjectList)
  private
    function GetItemN(iIndex: integer): TFhirCompartmentEntry;
  protected
    function ItemClass : TAdvObjectClass; override;
  public
    procedure add(key, ckey : integer; id : string);
    procedure removeById(id : String);
    Property Item[iCompartmentEntry : integer] : TFhirCompartmentEntry read GetItemN; default;
  end;

  TFhirIndexSpaces = class (TAdvObject)
  private
    FDB : TKDBConnection;
    FSpaces : TStringList;
  public
    constructor Create(db : TKDBConnection);
    destructor Destroy; override;
    function ResolveSpace(space : String):integer;
  end;

  {$HINTS OFF}
  TFhirIndexManager = class (TAdvObject)
  private
    FKeyEvent : TFHIRGetNextKey;
    FSpaces : TFhirIndexSpaces;
    FIndexes : TFhirIndexList;
    FComposites : TFhirCompositeList;
    FPatientCompartments : TFhirCompartmentEntryList;
    FEntries : TFhirIndexEntryList;
    FMasterKey : Integer;
    FNarrativeIndex : Integer;
    FBases : TStringList;
    FTerminologyServer : TTerminologyServerStore;

    procedure ReconcileIndexes;
    procedure GetBoundaries(value : String; comparator: TFhirQuantityComparator; var low, high : String);

    function EncodeXhtml(r : TFhirDomainResource) : TBytes;

    procedure buildIndexes;
    procedure buildIndexValues(key : integer; id : String; context, resource : TFhirResource);

    procedure patientCompartment(key : integer; reference : TFhirReference); overload;
    procedure patientCompartmentNot(key : integer; type_, id : String); overload;
    procedure patientCompartment(key : integer; type_, id : String); overload;

    // very primitives
    procedure index(aType : TFhirResourceType; key, parent : integer; value1, value2, name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value, name : String); overload;
    procedure index2(aType : TFhirResourceType; key, parent : integer; value, name : String); overload;

    // primitives
    procedure index(aType : TFhirResourceType; key, parent : integer; value : Boolean; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirString; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirUri; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirEnum; system, name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirInteger; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirBoolean; name : String); overload;

    // intervals of time
    procedure index(aType : TFhirResourceType; key, parent : integer; min, max : TDateTime; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirInstant; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirDateTime; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirDate; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirPeriod; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirTiming; name : String); overload;

    // complexes
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirRatio; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirQuantity; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirSampledData; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirCoding; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirCodingList; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirCodeableConcept; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirCodeableConceptList; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirIdentifier; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirIdentifierList; name : String); overload;
    procedure index(context : TFhirResource; aType : TFhirResourceType; key, parent : integer; value : TFhirReference; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirHumanName; name, phoneticName : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirAddress; name : String); overload;
    procedure index(aType : TFhirResourceType; key, parent : integer; value : TFhirContactPoint; name : String); overload;

    // structure holder
    function index(aType : TFhirResourceType; key, parent : integer; name : String) : Integer; overload;

    { resource functionality }
    {$IFNDEF FHIR-DSTU}
    procedure buildIndexValuesBundle(key : integer; id : string; context : TFhirResource; resource : TFhirBundle);
    {$ELSE}
    procedure buildIndexValuesAdverseReaction(key : integer; id : string; context : TFhirResource; resource : TFhirAdverseReaction);
    procedure BuildIndexValuesDeviceObservationReport(key : integer; id : string; context : TFhirResource; resource : TFhirDeviceObservationReport);
    procedure BuildIndexValuesQuery(key : integer; id : string; context : TFhirResource; resource : TFhirQuery);
    {$ENDIF}
    procedure buildIndexValuesAlert(key : integer; id : string; context : TFhirResource; resource : TFhirAlert);
    procedure buildIndexValuesAllergyIntolerance(key : integer; id : string; context : TFhirResource; resource : TFhirAllergyIntolerance);
    procedure buildIndexValuesBinary(key : integer; id : string; context : TFhirResource; resource : TFhirBinary);
    procedure BuildIndexValuesCarePlan(key : integer; id : string; context : TFhirResource; resource : TFhirCarePlan);
    procedure BuildIndexValuesCondition(key : integer; id : string; context : TFhirResource; resource : TFhirCondition);
    procedure BuildIndexValuesConformance(key : integer; id : string; context : TFhirResource; resource : TFhirConformance);
    procedure BuildIndexValuesDevice(key : integer; id : string; context : TFhirResource; resource : TFhirDevice);
    procedure BuildIndexValuesDiagnosticOrder(key : integer; id : string; context : TFhirResource; resource : TFhirDiagnosticOrder);
    procedure BuildIndexValuesDiagnosticReport(key : integer; id : string; context : TFhirResource; resource : TFhirDiagnosticReport);
    procedure BuildIndexValuesComposition(key : integer; id : string; context : TFhirResource; resource : TFhirComposition);
    procedure BuildIndexValuesDocumentReference(key : integer; id : string; context : TFhirResource; resource : TFhirDocumentReference);
    procedure BuildIndexValuesDocumentManifest(key : integer; id : string; context : TFhirResource; resource : TFhirDocumentManifest);
    procedure BuildIndexValuesEncounter(key : integer; id : string; context : TFhirResource; resource : TFhirEncounter);
    procedure buildIndexValuesFamilyHistory(key : integer; id : string; context : TFhirResource; resource : TFhirFamilyHistory);
    procedure BuildIndexValuesGroup(key : integer; id : string; context : TFhirResource; resource : TFhirGroup);
    procedure BuildIndexValuesImagingStudy(key : integer; id : string; context : TFhirResource; resource : TFhirImagingStudy);
    procedure BuildIndexValuesImmunization(key : integer; id : string; context : TFhirResource; resource : TFhirImmunization);
    procedure buildIndexValuesImmunizationRecommendation(key : integer; id : string; context : TFhirResource; resource : TFhirImmunizationRecommendation);
    procedure BuildIndexValuesList(key : integer; id : string; context : TFhirResource; resource : TFhirList);
    procedure BuildIndexValuesLocation(key : integer; id : string; context : TFhirResource; resource : TFhirLocation);
    procedure BuildIndexValuesMedia(key : integer; id : string; context : TFhirResource; resource : TFhirMedia);
    procedure BuildIndexValuesMedication(key : integer; id : string; context : TFhirResource; resource : TFhirMedication);
    procedure BuildIndexValuesMedicationAdministration(key : integer; id : string; context : TFhirResource; resource : TFhirMedicationAdministration);
    procedure BuildIndexValuesMedicationDispense(key : integer; id : string; context : TFhirResource; resource : TFhirMedicationDispense);
    procedure BuildIndexValuesMedicationPrescription(key : integer; id : string; context : TFhirResource; resource : TFhirMedicationPrescription);
    procedure BuildIndexValuesMedicationStatement(key : integer; id : string; context : TFhirResource; resource : TFhirMedicationStatement);
    procedure BuildIndexValuesMessageHeader(key : integer; id : string; context : TFhirResource; resource : TFhirMessageHeader);
    procedure BuildIndexValuesObservation(key : integer; id : string; context : TFhirResource; resource : TFhirObservation);
    procedure BuildIndexValuesOperationOutcome(key : integer; id : string; context : TFhirResource; resource : TFhirOperationOutcome);
    procedure BuildIndexValuesOrder(key : integer; id : string; context : TFhirResource; resource : TFhirOrder);
    procedure BuildIndexValuesOrderResponse(key : integer; id : string; context : TFhirResource; resource : TFhirOrderResponse);
    procedure BuildIndexValuesOrganization(key : integer; id : string; context : TFhirResource; resource : TFhirOrganization);
    procedure BuildIndexValuesPatient(key : integer; id : string; context : TFhirResource; resource : TFhirPatient);
    procedure BuildIndexValuesPractitioner(key : integer; id : string; context : TFhirResource; resource : TFhirPractitioner);
    procedure buildIndexValuesProcedure(key : integer; id : string; context : TFhirResource; resource : TFhirProcedure);
    procedure BuildIndexValuesProfile(key : integer; id : string; context : TFhirResource; resource : TFhirProfile);
    procedure BuildIndexValuesProvenance(key : integer; id : string; context : TFhirResource; resource : TFhirProvenance);
    procedure BuildIndexValuesQuestionnaire(key : integer; id : string; context : TFhirResource; resource : TFhirQuestionnaire);
    procedure BuildIndexValuesSecurityEvent(key : integer; id : string; context : TFhirResource; resource : TFhirSecurityEvent);
    procedure buildIndexValuesSpecimen(key : integer; id : string; context : TFhirResource; resource : TFhirSpecimen);
    procedure buildIndexValuesSubstance(key : integer; id : string; context : TFhirResource; resource : TFhirSubstance);
    procedure BuildIndexValuesValueSet(key : integer; id : string; context : TFhirResource; resource : TFhirValueSet);
    procedure BuildIndexValuesConceptMap(key : integer; id : string; context : TFhirResource; resource : TFhirConceptMap);
    procedure BuildIndexValuesRelatedPerson(key : integer; id : string; context : TFhirResource; resource : TFhirRelatedPerson);
    procedure BuildIndexValuesSupply(key : integer; id : string; context : TFhirResource; resource : TFhirSupply);
    procedure BuildIndexValuesOther(key : integer; id : string; context : TFhirResource; resource : TFhirOther);
  {$IFNDEF FHIR-DSTU}
    procedure BuildIndexValuesBasic(key : integer; id : string; context : TFhirResource; resource : TFhirBasic);
    procedure BuildIndexValuesQuestionnaireAnswers(key : integer; id : string; context : TFhirResource; resource : TFhirQuestionnaireAnswers);
    procedure BuildIndexValuesCarePlan2(key : integer; id : string; context : TFhirResource; resource : TFhirCarePlan2);
    procedure BuildIndexValuesSlot(key : integer; id : string; context : TFhirResource; resource : TFhirSlot);
    procedure BuildIndexValuesAppointment(key : integer; id : string; context : TFhirResource; resource : TFhirAppointment);
    procedure BuildIndexValuesSchedule(key : integer; id : string; context : TFhirResource; resource : TFhirSchedule);
    procedure BuildIndexValuesAppointmentResponse(key : integer; id : string; context : TFhirResource; resource : TFhirAppointmentResponse);
    procedure BuildIndexValuesHealthcareService(key : integer; id : string; context : TFhirResource; resource : TFhirHealthcareService);
    procedure BuildIndexValuesDataElement(key : integer; id : string; context : TFhirResource; resource : TFhirDataElement);
    procedure BuildIndexValuesNamingSystem(key : integer; id : string; context : TFhirResource; resource : TFhirNamingSystem);
    procedure BuildIndexValuesSubscription(key : integer; id : string; context : TFhirResource; resource : TFhirSubscription);
    procedure BuildIndexValuesContraIndication(key : integer; id : string; context : TFhirResource; resource : TFhirContraIndication);
    procedure BuildIndexValuesRiskAssessment(key : integer; id : string; context : TFhirResource; resource : TFhirRiskAssessment);
    procedure BuildIndexValuesOperationDefinition(key : integer; id : string; context : TFhirResource; resource : TFhirOperationDefinition);
    procedure BuildIndexValuesReferralRequest(key : integer; id : string; context : TFhirResource; resource : TFhirReferralRequest);
    procedure BuildIndexValuesNutritionOrder(key : integer; id : string; context : TFhirResource; resource : TFhirNutritionOrder);
    procedure BuildIndexValuesCoverage(key : integer; id : string; context : TFhirResource; resource : TFhirCoverage);
    procedure BuildIndexValuesClaimResponse(key : integer; id : string; context : TFhirResource; resource : TFhirClaimResponse);
    procedure BuildIndexValuesOralHealthClaim(key : integer; id : string; context : TFhirResource; resource : TFhirOralHealthClaim);
    procedure BuildIndexValuesContract(key : integer; id : string; context : TFhirResource; resource : TFhirContract);
    procedure BuildIndexValuesClinicalAssessment(key : integer; id : string; context : TFhirResource; resource : TFhirClinicalAssessment);
    procedure BuildIndexValuesCommunication(key : integer; id : string; context : TFhirResource; resource : TFhirCommunication);
    procedure BuildIndexValuesCommunicationRequest(key : integer; id : string; context : TFhirResource; resource : TFhirCommunicationRequest);
    procedure BuildIndexValuesDeviceComponent(key : integer; id : string; context : TFhirResource; resource : TFhirDeviceComponent);
    procedure BuildIndexValuesDeviceMetric(key : integer; id : string; context : TFhirResource; resource : TFhirDeviceMetric);
    procedure BuildIndexValuesDeviceUseRequest(key : integer; id : string; context : TFhirResource; resource : TFhirDeviceUseRequest);
    procedure BuildIndexValuesDeviceUseStatement(key : integer; id : string; context : TFhirResource; resource : TFhirDeviceUseStatement);
    procedure BuildIndexValuesEligibilityRequest(key : integer; id : string; context : TFhirResource; resource : TFhirEligibilityRequest);
    procedure BuildIndexValuesEligibilityResponse(key : integer; id : string; context : TFhirResource; resource : TFhirEligibilityResponse);
    procedure BuildIndexValuesEnrollmentRequest(key : integer; id : string; context : TFhirResource; resource : TFhirEnrollmentRequest);
    procedure BuildIndexValuesEnrollmentResponse(key : integer; id : string; context : TFhirResource; resource : TFhirEnrollmentResponse);
    procedure BuildIndexValuesEpisodeOfCare(key : integer; id : string; context : TFhirResource; resource : TFhirEpisodeOfCare);
    procedure BuildIndexValuesExplanationOfBenefit(key : integer; id : string; context : TFhirResource; resource : TFhirExplanationOfBenefit);
    procedure BuildIndexValuesExtensionDefinition(key : integer; id : string; context : TFhirResource; resource : TFhirExtensionDefinition);
    procedure BuildIndexValuesGoal(key : integer; id : string; context : TFhirResource; resource : TFhirGoal);
    procedure BuildIndexValuesImagingObjectSelection(key : integer; id : string; context : TFhirResource; resource : TFhirImagingObjectSelection);
    procedure BuildIndexValuesInstitutionalClaim(key : integer; id : string; context : TFhirResource; resource : TFhirInstitutionalClaim);
    procedure BuildIndexValuesPaymentNotice(key : integer; id : string; context : TFhirResource; resource : TFhirPaymentNotice);
    procedure BuildIndexValuesPaymentReconciliation(key : integer; id : string; context : TFhirResource; resource : TFhirPaymentReconciliation);
    procedure BuildIndexValuesPendedRequest(key : integer; id : string; context : TFhirResource; resource : TFhirPendedRequest);
    procedure BuildIndexValuesPerson(key : integer; id : string; context : TFhirResource; resource : TFhirPerson);
    procedure BuildIndexValuesPharmacyClaim(key : integer; id : string; context : TFhirResource; resource : TFhirPharmacyClaim);
    procedure BuildIndexValuesProcedureRequest(key : integer; id : string; context : TFhirResource; resource : TFhirProcedureRequest);
    procedure BuildIndexValuesProfessionalClaim(key : integer; id : string; context : TFhirResource; resource : TFhirProfessionalClaim);
    procedure BuildIndexValuesReadjudicate(key : integer; id : string; context : TFhirResource; resource : TFhirReadjudicate);
    procedure BuildIndexValuesReversal(key : integer; id : string; context : TFhirResource; resource : TFhirReversal);
    procedure BuildIndexValuesSearchParameter(key : integer; id : string; context : TFhirResource; resource : TFhirSearchParameter);
    procedure BuildIndexValuesStatusRequest(key : integer; id : string; context : TFhirResource; resource : TFhirStatusRequest);
    procedure BuildIndexValuesStatusResponse(key : integer; id : string; context : TFhirResource; resource : TFhirStatusResponse);
    procedure BuildIndexValuesSupportingDocumentation(key : integer; id : string; context : TFhirResource; resource : TFhirSupportingDocumentation);
    procedure BuildIndexValuesVisionClaim(key : integer; id : string; context : TFhirResource; resource : TFhirVisionClaim);
    procedure BuildIndexValuesVisionPrescription(key : integer; id : string; context : TFhirResource; resource : TFhirVisionPrescription);

    procedure buildIndexesBundle;
  {$ENDIF}

    procedure buildIndexesAlert;
    procedure buildIndexesAllergyIntolerance;
    procedure buildIndexesCarePlan;
    procedure buildIndexesConformance;
    procedure buildIndexesDevice;
    procedure buildIndexesDiagnosticReport;
    procedure buildIndexesDiagnosticOrder;
    procedure buildIndexesComposition;
    procedure buildIndexesDocumentReference;
    procedure buildIndexesDocumentManifest;
    procedure buildIndexesFamilyHistory;
    procedure buildIndexesEncounter;
    procedure buildIndexesGroup;
    procedure buildIndexesImagingStudy;
    procedure buildIndexesImmunization;
    procedure buildIndexesImmunizationRecommendation;
    procedure buildIndexesOperationOutcome;
    procedure buildIndexesList;
    procedure buildIndexesLocation;
    procedure buildIndexesMedication;
    procedure buildIndexesMedicationAdministration;
    procedure buildIndexesMedicationPrescription;
    procedure buildIndexesMedicationDispense;
    procedure buildIndexesMedicationStatement;
    procedure buildIndexesMessageHeader;
    procedure buildIndexesObservation;
    procedure buildIndexesOrder;
    procedure buildIndexesOrderResponse;
    procedure buildIndexesOrganization;
    procedure buildIndexesPatient;
    procedure buildIndexesMedia;
    procedure buildIndexesProcedure;
    procedure buildIndexesCondition;
    procedure buildIndexesProfile;
    procedure buildIndexesProvenance;
    procedure buildIndexesPractitioner;
    procedure buildIndexesQuestionnaire;
    procedure buildIndexesSecurityEvent;
    procedure buildIndexesValueSet;
    procedure BuildIndexesConceptMap;
    procedure buildIndexesSpecimen;
    procedure buildIndexesSubstance;
    procedure buildIndexesBinary;
    procedure BuildIndexesRelatedPerson;
    procedure BuildIndexesSupply;
    procedure BuildIndexesOther;
  {$IFNDEF FHIR-DSTU}
    procedure BuildIndexesCoverage;
    procedure BuildIndexesClaimResponse;
    procedure BuildIndexesContract;
    procedure BuildIndexesOralHealthClaim;
    procedure BuildIndexesBasic;
    procedure buildIndexesQuestionnaireAnswers;
    procedure BuildIndexesSlot;
    procedure BuildIndexesAppointment;
    procedure BuildIndexesSchedule;
    procedure BuildIndexesAppointmentResponse;
    procedure BuildIndexesHealthcareService;
    procedure BuildIndexesDataElement;
    procedure BuildIndexesNamingSystem;
    procedure BuildIndexesSubscription;
    procedure BuildIndexesContraIndication;
    procedure BuildIndexesRiskAssessment;
    procedure BuildIndexesOperationDefinition;
    procedure BuildIndexesReferralRequest;
    procedure BuildIndexesNutritionOrder;
    procedure buildIndexesCarePlan2;
    procedure buildIndexesClinicalAssessment;
    procedure buildIndexesCommunication;
    procedure buildIndexesCommunicationRequest;
    procedure buildIndexesDeviceComponent;
    procedure buildIndexesDeviceMetric;
    procedure buildIndexesDeviceUseRequest;
    procedure buildIndexesDeviceUseStatement;
    procedure buildIndexesEligibilityRequest;
    procedure buildIndexesEligibilityResponse;
    procedure buildIndexesEnrollmentRequest;
    procedure buildIndexesEnrollmentResponse;
    procedure buildIndexesEpisodeOfCare;
    procedure buildIndexesExplanationOfBenefit;
    procedure buildIndexesExtensionDefinition;
    procedure buildIndexesGoal;
    procedure buildIndexesImagingObjectSelection;
    procedure buildIndexesInstitutionalClaim;
    procedure buildIndexesPaymentNotice;
    procedure buildIndexesPaymentReconciliation;
    procedure buildIndexesPendedRequest;
    procedure buildIndexesPerson;
    procedure buildIndexesPharmacyClaim;
    procedure buildIndexesProcedureRequest;
    procedure buildIndexesProfessionalClaim;
    procedure buildIndexesReadjudicate;
    procedure buildIndexesReversal;
    procedure buildIndexesSearchParameter;
    procedure buildIndexesStatusRequest;
    procedure buildIndexesStatusResponse;
    procedure buildIndexesSupportingDocumentation;
    procedure buildIndexesVisionClaim;
    procedure buildIndexesVisionPrescription;
  {$ELSE}
    procedure buildIndexesQuery;
    procedure buildIndexesAdverseReaction;
    procedure buildIndexesDeviceObservationReport;
  {$ENDIF}

    procedure processCompartmentTags(key : integer; id: String; tags : TFHIRAtomCategoryList);
    procedure processUnCompartmentTags(key : integer; id: String; tags : TFHIRAtomCategoryList);
    procedure SetTerminologyServer(const Value: TTerminologyServerStore);

  public
    constructor Create(aSpaces : TFhirIndexSpaces);
    destructor Destroy; override;
    function Link : TFHIRIndexManager; overload;
    property Indexes : TFhirIndexList read FIndexes;
    property Composites : TFhirCompositeList read FComposites;
    property TerminologyServer : TTerminologyServerStore read FTerminologyServer write SetTerminologyServer;
    property Bases : TStringList read FBases write FBases;
    function execute(key : integer; id: String; resource : TFhirResource; tags : TFHIRAtomCategoryList) : String;
    Function GetKeyByName(types : TFhirResourceTypeSet; name : String) : integer;
    Function GetTypeByName(types : TFhirResourceTypeSet; name : String) : TFhirSearchParamType;
    Function GetComposite(types : TFhirResourceTypeSet; name : String; var otypes : TFhirResourceTypeSet) : TFhirComposite;
    Function GetTargetsByName(types : TFhirResourceTypeSet; name : String) : TFhirResourceTypeSet;
    property KeyEvent : TFHIRGetNextKey read FKeyEvent write FKeyEvent;
    Property NarrativeIndex : integer read FNarrativeIndex;
    class function noIndexing(a: TFhirResourceType): boolean; static;
  end;

function normaliseDecimal(v : String): String;
  
implementation

Function EncodeNYSIISValue(value : TFhirString) : String; overload;
begin
  result := EncodeNYSIIS(value.value);
end;


{ TFhirIndex }

procedure TFhirIndex.assign(source: TAdvObject);
begin
  inherited;
  FKey := TFhirIndex(source).FKey;
  FName := TFhirIndex(source).FName;
  FSearchType := TFhirIndex(source).FSearchType;
  FResourceType := TFhirIndex(source).FResourceType;
  TargetTypes := TFhirIndex(source).TargetTypes;
end;

function TFhirIndex.Clone: TFhirIndex;
begin
  result := TFhirIndex(Inherited Clone);
end;

function TFhirIndex.Link: TFhirIndex;
begin
  result := TFhirIndex(Inherited Link);
end;

{ TFhirIndexList }

procedure TFhirIndexList.add(aResourceType : TFhirResourceType; name, description : String; aType : TFhirSearchParamType; aTargetTypes : TFhirResourceTypeSet);
var
  ndx : TFhirIndex;
begin
  ndx := TFhirIndex.Create;
  try
    ndx.ResourceType := aResourceType;
    ndx.name := name;
    ndx.SearchType := aType;
    ndx.TargetTypes := aTargetTypes;
    ndx.description := description;
    inherited add(ndx.Link);
  finally
    ndx.free;
  end;
end;


function TFhirIndexList.getByName(atype : TFhirResourceType; name: String): TFhirIndex;
var
  i : integer;
begin
  i := 0;
  result := nil;
  while (result = nil) and (i < Count) do
  begin
    if SameText(item[i].name, name) and (item[i].FResourceType = atype) then
      result := item[i];
    inc(i);
  end;
end;

function TFhirIndexList.GetItemN(iIndex: integer): TFhirIndex;
begin
  result := TFhirIndex(ObjectByIndex[iIndex]);
end;

function TFhirIndexList.ItemClass: TAdvObjectClass;
begin
  result := TFhirIndex;
end;

function TFhirIndexList.Link: TFhirIndexList;
begin
  result := TFhirIndexList(Inherited Link);
end;

function findPrefix(var value : String; subst : String) : boolean;
begin
  result := value.StartsWith(subst);
  if result then
    value := value.Substring(subst.Length);
end;

function normaliseDecimal(v : String): String;
var
  neg : boolean;
begin
  neg := findPrefix(v, '-');
  if not v.Contains('.') then
    result := StringPadRight(StringPadLeft(v, '0', 40)+'.', '0', 91)
  else if (v.IndexOf('.') > 40) or (v.IndexOf('.') < v.Length-50) then
    raise Exception.Create('Cannot normalise '+v)
  else
    result := StringPadRight(StringPadLeft('', '0', 40-v.IndexOf('.'))+v, '0', 91);
  if neg then
    result := '-' + result;
end;

{ TFhirIndexEntryList }

function TFhirIndexEntryList.add(key, parent : integer; index: TFhirIndex; ref: integer; value1, value2: String; target : Integer; type_ : TFhirSearchParamType; flag : boolean = false; concept : integer = 0) : integer;
var
  entry : TFhirIndexEntry;
begin
  if (Index.Key = 0) then
    raise Exception.create('unknown index '+index.Name);

  case type_ of
    SearchParamTypeNumber, SearchParamTypeQuantity :
      begin
        value1 := normaliseDecimal(value1);
        value2 := normaliseDecimal(value2);
      end;
    SearchParamTypeString :
      begin
        value1 := removeCaseAndAccents(value1);
        value2 := removeCaseAndAccents(value2);
      end;
    SearchParamTypeDate : ; // nothing
    SearchParamTypeToken :
      begin
      value2 := removeCaseAndAccents(value2);
      end;
    SearchParamTypeReference : ; // nothing
  else
    // null, Composite
    raise exception.create('Unhandled type generating index');
  end;

  entry := TFhirIndexEntry.create;
  try
    entry.EntryKey := KeyEvent(ktEntries);
    result := entry.EntryKey;
    entry.IndexKey := index.Key;
    entry.key := key;
    entry.parent := parent;
    entry.Value1 := lowercase(value1);
    entry.Value2 := lowercase(value2);
    entry.RefType := ref;
    entry.type_ := type_;
    entry.target := target;
    entry.concept := concept;
    entry.flag := flag;
    Inherited Add(entry.Link);
  finally
    entry.free;
  end;
end;


function TFhirIndexEntryList.add(key, parent: integer; index: TFhirComposite): integer;
var
  entry : TFhirIndexEntry;
begin
  if (Index.Key = 0) then
    raise Exception.create('unknown index '+index.Name);

  entry := TFhirIndexEntry.create;
  try
    entry.EntryKey := KeyEvent(ktEntries);
    result := entry.EntryKey;
    entry.IndexKey := index.Key;
    entry.key := key;
    entry.parent := parent;
    Inherited Add(entry.Link);
  finally
    entry.free;
  end;
end;

function TFhirIndexEntryList.GetItemN(iIndex: integer): TFhirIndexEntry;
begin
  result := TFhirIndexEntry(objectByindex[iIndex]);
end;

function TFhirIndexEntryList.ItemClass: TAdvObjectClass;
begin
  result := TFhirIndexEntry;
end;

{ TFhirIndexManager }

constructor TFhirIndexManager.Create(aSpaces : TFhirIndexSpaces);
begin
  inherited Create;
  FPatientCompartments := TFhirCompartmentEntryList.create;
  FSpaces := TFhirIndexSpaces(aSpaces.Link);
  FIndexes := TFhirIndexList.create;
  FComposites := TFhirCompositeList.create;
  buildIndexes;

  FEntries := TFhirIndexEntryList.Create;
  if FSpaces <> nil then
    ReconcileIndexes;
end;

destructor TFhirIndexManager.Destroy;
begin
  FTerminologyServer.free;
  FPatientCompartments.Free;
  FSpaces.Free;
  FEntries.Free;
  FIndexes.Free;
  FComposites.Free;
  inherited;
end;

class function TFhirIndexManager.noIndexing(a : TFhirResourceType) : boolean;
begin
  {$IFDEF FHIR-DSTU}
  result := false;
  {$ELSE}
  result := a in [frtParameters];
  {$ENDIF}
end;

procedure TFhirIndexManager.buildIndexes;
var
  i : TFhirResourceType;
begin
  // the order of these matters when building search forms
  buildIndexesPractitioner;
  buildIndexesPatient;
  buildIndexesOrganization;

  buildIndexesAlert;
  buildIndexesAllergyIntolerance;
  buildIndexesCarePlan;
  buildIndexesConformance;
  buildIndexesDevice;
  buildIndexesDiagnosticReport;
  buildIndexesDiagnosticOrder;
  buildIndexesComposition;
  buildIndexesDocumentReference;
  buildIndexesDocumentManifest;
  buildIndexesFamilyHistory;
  buildIndexesGroup;
  buildIndexesImagingStudy;
  buildIndexesImmunization;
  buildIndexesImmunizationRecommendation;
  buildIndexesOperationOutcome;
  buildIndexesList;
  buildIndexesLocation;
  buildIndexesMedicationAdministration;
  buildIndexesMedication;
  buildIndexesMedicationPrescription;
  buildIndexesMedicationDispense;
  buildIndexesMedicationStatement;
  buildIndexesMessageHeader;
  buildIndexesObservation;
  buildIndexesOrder;
  buildIndexesOrderResponse;
  buildIndexesMedia;
  buildIndexesCondition;
  buildIndexesProcedure;
  buildIndexesProfile;
  buildIndexesProvenance;
  buildIndexesQuestionnaire;
  buildIndexesSecurityEvent;
  buildIndexesSpecimen;
  buildIndexesSubstance;
  buildIndexesValueSet;
  buildIndexesConceptMap;
  buildIndexesEncounter;
  BuildIndexesRelatedPerson;
  BuildIndexesSupply;
  BuildIndexesOther;

  {$IFNDEF FHIR-DSTU}
  buildIndexesBundle;
  BuildIndexesCoverage;
  BuildIndexesClaimResponse;
  BuildIndexesContract;
  BuildIndexesOralHealthClaim;
  BuildIndexesBasic;
  buildIndexesQuestionnaireAnswers;
  BuildIndexesSlot;
  BuildIndexesAppointment;
  BuildIndexesSchedule;
  BuildIndexesAppointmentResponse;
  BuildIndexesHealthcareService;
  BuildIndexesDataElement;
  BuildIndexesNamingSystem;
  BuildIndexesSubscription;
  BuildIndexesContraIndication;
  BuildIndexesRiskAssessment;
  BuildIndexesOperationDefinition;
  BuildIndexesReferralRequest;
  BuildIndexesNutritionOrder;
  buildIndexesCarePlan2;
  buildIndexesClinicalAssessment;
  buildIndexesCommunication;
  buildIndexesCommunicationRequest;
  buildIndexesDeviceComponent;
  buildIndexesDeviceMetric;
  buildIndexesDeviceUseRequest;
  buildIndexesDeviceUseStatement;
  buildIndexesEligibilityRequest;
  buildIndexesEligibilityResponse;
  buildIndexesEnrollmentRequest;
  buildIndexesEnrollmentResponse;
  buildIndexesEpisodeOfCare;
  buildIndexesExplanationOfBenefit;
  buildIndexesExtensionDefinition;
  buildIndexesGoal;
  buildIndexesImagingObjectSelection;
  buildIndexesInstitutionalClaim;
  buildIndexesPaymentNotice;
  buildIndexesPaymentReconciliation;
  buildIndexesPendedRequest;
  buildIndexesPerson;
  buildIndexesPharmacyClaim;
  buildIndexesProcedureRequest;
  buildIndexesProfessionalClaim;
  buildIndexesReadjudicate;
  buildIndexesReversal;
  buildIndexesSearchParameter;
  buildIndexesStatusRequest;
  buildIndexesStatusResponse;
  buildIndexesSupportingDocumentation;
  buildIndexesVisionClaim;
  buildIndexesVisionPrescription;
  {$ELSE}
  buildIndexesQuery;
  buildIndexesAdverseReaction;
  buildIndexesDeviceObservationReport;
  {$ENDIF}
  buildIndexesBinary;

  for I := TFhirResourceType(1) to High(TFhirResourceType) do
    if not noIndexing(I) and (FIndexes.getByName(i, '_id') = nil) then
    begin
      writeln('No registration for '+CODES_TFHIRResourceType[i]);
      raise Exception.Create('No registration for '+CODES_TFHIRResourceType[i]);
    end;

end;

procedure TFhirIndexManager.buildIndexValues(key : integer; id : string; context, resource: TFhirResource);
begin
  case resource.ResourceType of
    frtBinary : buildIndexValuesBinary(key, id, context, TFhirBinary(resource));
    frtAlert : buildIndexValuesAlert(key, id, context, TFhirAlert(resource));
    frtAllergyIntolerance : buildIndexValuesAllergyIntolerance(key, id, context, TFhirAllergyIntolerance(resource));
    frtCarePlan : buildIndexValuesCarePlan(key, id, context, TFhirCarePlan(resource));
    frtConformance : buildIndexValuesConformance(key, id, context, TFhirConformance(resource));
    frtDevice : buildIndexValuesDevice(key, id, context, TFhirDevice(resource));
    frtDiagnosticReport : buildIndexValuesDiagnosticReport(key, id, context, TFhirDiagnosticReport(resource));
    frtDiagnosticOrder : buildIndexValuesDiagnosticOrder(key, id, context, TFhirDiagnosticOrder(resource));
    frtComposition : buildIndexValuesComposition(key, id, context, TFhirComposition(resource));
    frtDocumentReference : buildIndexValuesDocumentReference(key, id, context, TFhirDocumentReference(resource));
    frtDocumentManifest : buildIndexValuesDocumentManifest(key, id, context, TFhirDocumentManifest(resource));
    frtFamilyHistory : buildIndexValuesFamilyHistory(key, id, context, TFhirFamilyHistory(resource));
    frtGroup : buildIndexValuesGroup(key, id, context, TFhirGroup(resource));
    frtImagingStudy : buildIndexValuesImagingStudy(key, id, context, TFhirImagingStudy(resource));
    frtImmunization : buildIndexValuesImmunization(key, id, context, TFhirImmunization(resource));
    frtImmunizationRecommendation : buildIndexValuesImmunizationRecommendation(key, id, context, TFhirImmunizationRecommendation(resource));
    frtOperationOutcome : buildIndexValuesOperationOutcome(key, id, context, TFhirOperationOutcome(resource));
    frtList : buildIndexValuesList(key, id, context, TFhirList(resource));
    frtLocation : buildIndexValuesLocation(key, id, context, TFhirLocation(resource));
    frtMedication : buildIndexValuesMedication(key, id, context, TFhirMedication(resource));
    frtMedicationAdministration : buildIndexValuesMedicationAdministration(key, id, context, TFhirMedicationAdministration(resource));
    frtMedicationPrescription : buildIndexValuesMedicationPrescription(key, id, context, TFhirMedicationPrescription(resource));
    frtMedicationDispense : buildIndexValuesMedicationDispense(key, id, context, TFhirMedicationDispense(resource));
    frtMedicationStatement : buildIndexValuesMedicationStatement(key, id, context, TFhirMedicationStatement(resource));
    frtMessageHeader : buildIndexValuesMessageHeader(key, id, context, TFhirMessageHeader(resource));
    frtObservation : buildIndexValuesObservation(key, id, context, TFhirObservation(resource));
    frtOrder : buildIndexValuesOrder(key, id, context, TFhirOrder(resource));
    frtOrderResponse : buildIndexValuesOrderResponse(key, id, context, TFhirOrderResponse(resource));
    frtOrganization : buildIndexValuesOrganization(key, id, context, TFhirOrganization(resource));
    frtPatient : buildIndexValuesPatient(key, id, context, TFhirPatient(resource));
    frtMedia : buildIndexValuesMedia(key, id, context, TFhirMedia(resource));
    frtPractitioner : buildIndexValuesPractitioner(key, id, context, TFhirPractitioner(resource));
    frtCondition : buildIndexValuesCondition(key, id, context, TFhirCondition(resource));
    frtProcedure : buildIndexValuesProcedure(key, id, context, TFhirProcedure(resource));
    frtProfile : buildIndexValuesProfile(key, id, context, TFhirProfile(resource));
    frtProvenance : buildIndexValuesProvenance(key, id, context, TFhirProvenance(resource));
    frtQuestionnaire : buildIndexValuesQuestionnaire(key, id, context, TFhirQuestionnaire(resource));
    frtSecurityEvent : buildIndexValuesSecurityEvent(key, id, context, TFhirSecurityEvent(resource));
    frtSpecimen : buildIndexValuesSpecimen(key, id, context, TFhirSpecimen(resource));
    frtSubstance : buildIndexValuesSubstance(key, id, context, TFhirSubstance(resource));
    frtValueSet : buildIndexValuesValueSet(key, id, context, TFhirValueSet(resource));
    frtConceptMap : buildIndexValuesConceptMap(key, id, context, TFhirConceptMap(resource));
    frtEncounter : buildIndexValuesEncounter(key, id, context, TFhirEncounter(resource));
    frtRelatedPerson : buildIndexValuesRelatedPerson(key, id, context, TFhirRelatedPerson(resource));
    frtSupply : buildIndexValuesSupply(key, id, context, TFhirSupply(resource));
    frtOther : buildIndexValuesOther(key, id, context, TFhirOther(resource));
    {$IFNDEF FHIR-DSTU}
    frtBundle : buildIndexValuesBundle(key, id, context, TFhirBundle(resource));
    frtCarePlan2 : buildIndexValuesCarePlan2(key, id, context, TFhirCarePlan2(resource));
    frtClinicalAssessment : buildIndexValuesClinicalAssessment(key, id, context, TFhirClinicalAssessment(resource));
    frtCommunication : buildIndexValuesCommunication(key, id, context, TFhirCommunication(resource));
    frtCommunicationRequest : buildIndexValuesCommunicationRequest(key, id, context, TFhirCommunicationRequest(resource));
    frtDeviceComponent : buildIndexValuesDeviceComponent(key, id, context, TFhirDeviceComponent(resource));
    frtDeviceMetric : buildIndexValuesDeviceMetric(key, id, context, TFhirDeviceMetric(resource));
    frtDeviceUseRequest : buildIndexValuesDeviceUseRequest(key, id, context, TFhirDeviceUseRequest(resource));
    frtDeviceUseStatement : buildIndexValuesDeviceUseStatement(key, id, context, TFhirDeviceUseStatement(resource));
    frtEligibilityRequest : buildIndexValuesEligibilityRequest(key, id, context, TFhirEligibilityRequest(resource));
    frtEligibilityResponse : buildIndexValuesEligibilityResponse(key, id, context, TFhirEligibilityResponse(resource));
    frtEnrollmentRequest : buildIndexValuesEnrollmentRequest(key, id, context, TFhirEnrollmentRequest(resource));
    frtEnrollmentResponse : buildIndexValuesEnrollmentResponse(key, id, context, TFhirEnrollmentResponse(resource));
    frtEpisodeOfCare : buildIndexValuesEpisodeOfCare(key, id, context, TFhirEpisodeOfCare(resource));
    frtExplanationOfBenefit : buildIndexValuesExplanationOfBenefit(key, id, context, TFhirExplanationOfBenefit(resource));
    frtExtensionDefinition : buildIndexValuesExtensionDefinition(key, id, context, TFhirExtensionDefinition(resource));
    frtGoal : buildIndexValuesGoal(key, id, context, TFhirGoal(resource));
    frtImagingObjectSelection : buildIndexValuesImagingObjectSelection(key, id, context, TFhirImagingObjectSelection(resource));
    frtInstitutionalClaim : buildIndexValuesInstitutionalClaim(key, id, context, TFhirInstitutionalClaim(resource));
    frtPaymentNotice : buildIndexValuesPaymentNotice(key, id, context, TFhirPaymentNotice(resource));
    frtPaymentReconciliation : buildIndexValuesPaymentReconciliation(key, id, context, TFhirPaymentReconciliation(resource));
    frtPendedRequest : buildIndexValuesPendedRequest(key, id, context, TFhirPendedRequest(resource));
    frtPerson : buildIndexValuesPerson(key, id, context, TFhirPerson(resource));
    frtPharmacyClaim : buildIndexValuesPharmacyClaim(key, id, context, TFhirPharmacyClaim(resource));
    frtProcedureRequest : buildIndexValuesProcedureRequest(key, id, context, TFhirProcedureRequest(resource));
    frtProfessionalClaim : buildIndexValuesProfessionalClaim(key, id, context, TFhirProfessionalClaim(resource));
    frtReadjudicate : buildIndexValuesReadjudicate(key, id, context, TFhirReadjudicate(resource));
    frtReversal : buildIndexValuesReversal(key, id, context, TFhirReversal(resource));
    frtSearchParameter : buildIndexValuesSearchParameter(key, id, context, TFhirSearchParameter(resource));
    frtStatusRequest : buildIndexValuesStatusRequest(key, id, context, TFhirStatusRequest(resource));
    frtStatusResponse : buildIndexValuesStatusResponse(key, id, context, TFhirStatusResponse(resource));
    frtSupportingDocumentation : buildIndexValuesSupportingDocumentation(key, id, context, TFhirSupportingDocumentation(resource));
    frtVisionClaim : buildIndexValuesVisionClaim(key, id, context, TFhirVisionClaim(resource));
    frtVisionPrescription : buildIndexValuesVisionPrescription(key, id, context, TFhirVisionPrescription(resource));
    frtCoverage : buildIndexValuesCoverage(key, id, context, TFhirCoverage(resource));
    frtClaimResponse : buildIndexValuesClaimResponse(key, id, context, TFhirClaimResponse(resource));
    frtContract : buildIndexValuesContract(key, id, context, TFhirContract(resource));
    frtOralHealthClaim : buildIndexValuesOralHealthClaim(key, id, context, TFhirOralHealthClaim(resource));
    frtBasic : buildIndexValuesBasic(key, id, context, TFhirBasic(resource));
    frtQuestionnaireAnswers : buildIndexValuesQuestionnaireAnswers(key, id, context, TFhirQuestionnaireAnswers(resource));
    frtSlot : BuildIndexValuesSlot(key, id, context, TFhirSlot(resource));
    frtAppointment : BuildIndexValuesAppointment(key, id, context, TFhirAppointment(resource));
    frtSchedule : BuildIndexValuesSchedule(key, id, context, TFhirSchedule(resource));
    frtAppointmentResponse : BuildIndexValuesAppointmentResponse(key, id, context, TFhirAppointmentResponse(resource));
    frtHealthcareService : BuildIndexValuesHealthcareService(key, id, context, TFhirHealthcareService(resource));
    frtDataElement : BuildIndexValuesDataElement(key, id, context, TFhirDataElement(resource));
    frtNamingSystem : BuildIndexValuesNamingSystem(key, id, context, TFhirNamingSystem(resource));
    frtSubscription : BuildIndexValuesSubscription(key, id, context, TFhirSubscription(resource));
    frtContraIndication : BuildIndexValuesContraIndication(key, id, context, TFhirContraIndication(resource));
    frtRiskAssessment : BuildIndexValuesRiskAssessment(key, id, context, TFhirRiskAssessment(resource));
    frtOperationDefinition : BuildIndexValuesOperationDefinition(key, id, context, TFhirOperationDefinition(resource));
    frtReferralRequest : BuildIndexValuesReferralRequest(key, id, context, TFhirReferralRequest(resource));
    frtNutritionOrder : BuildIndexValuesNutritionOrder(key, id, context, TFhirNutritionOrder(resource));
    {$ELSE}
    frtDeviceObservationReport : buildIndexValuesDeviceObservationReport(key, id, context, TFhirDeviceObservationReport(resource));
    frtAdverseReaction : buildIndexValuesAdverseReaction(key, id, context, TFhirAdverseReaction(resource));
    frtQuery : buildIndexValuesQuery(key, id, context, TFhirQuery(resource));
    {$ENDIF}

  else
    raise Exception.create('resource type indexing not implemented yet for '+CODES_TFhirResourceType[resource.ResourceType]);
  end;
end;


function TFhirIndexManager.EncodeXhtml(r: TFhirDomainResource): TBytes;
var
  b : TBytesStream;
  x, body : TFhirXHtmlNode;
  xc : TAdvXmlBuilder;
  fc : TFHIRXmlComposer;
begin
  b :=  TBytesStream.Create;
  try
    if r.ResourceType <> frtBinary then
    begin
      x := TFhirXHtmlNode.Create;
      try
        x.NodeType := fhntElement;
        x.Name := 'html';
        x.AddChild('head').AddChild('title').AddText(CODES_TFhirResourceType[r.ResourceType]);
        body := x.AddChild('body');
        if (r.language = '') then
          body.SetAttribute('lang', 'en')
        else
          body.SetAttribute('lang', r.language);
        if (r.text <> nil) and (r.text.div_ <> nil) then
          body.ChildNodes.Add(r.text.div_.Link);
        xc := TAdvXmlBuilder.Create;
        try
          xc.Start;
          fc := TFHIRXmlComposer.Create('en');
          try
            fc.ComposeXHtmlNode(xc, 'html', x);
          finally
            fc.Free;
          end;
          xc.Finish;
          xc.Build(b);
        finally
          xc.Free;
        end;
      finally
        x.Free;
      end;
    end;
    result := copy(b.Bytes, 0, b.size); // don't compress, sql server has to read it.
  finally
    b.free;
  end;
end;


procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirString; name: String);
begin
  if (value <> nil) then
    index(aType, key, parent, value.value, name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirUri; name: String);
begin
  if (value <> nil) then
    index(aType, key, parent, value.value, name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirCodeableConcept; name: String);
var
  i : integer;
begin
  if value <> nil then
  begin
    for i := 0 to value.codingList.count - 1 do
      index(aType, key, parent, value.codingList[i], name);
    if value.text <> '' then
      index2(aType, key, parent, value.text, name);
  End;
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value, name: String);
var
  ndx : TFhirIndex;
  types : TFhirSearchParamTypeList;

begin
  if (value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name+' on type '+CODES_TFhirResourceType[aType]);

  if StringIsInteger32(value) then
    types := [SearchParamTypeString, SearchParamTypeToken, SearchParamTypeDate, SearchParamTypeReference, SearchParamTypeNumber]
  else
    types := [SearchParamTypeString, SearchParamTypeToken, SearchParamTypeDate, SearchParamTypeReference];
  if not (ndx.SearchType in types) then //todo: fix up text
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing string');
  if ndx.SearchType = SearchParamTypeString then
    value := lowercase(RemoveAccents(copy(value, 1, INDEX_ENTRY_LENGTH)))
  else if (length(value) > INDEX_ENTRY_LENGTH) then
     raise exception.create('string too long for indexing: '+value+ ' ('+inttostr(length(value))+' chars)');
  FEntries.add(key, parent, ndx, 0, value, '', 0, ndx.SearchType);
end;

procedure TFhirIndexManager.index2(aType : TFhirResourceType; key, parent : integer; value, name: String);
var
  ndx : TFhirIndex;
begin
  if (value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name+' on type '+CODES_TFhirResourceType[aType]);
  if not (ndx.SearchType in [SearchParamTypeToken, SearchParamTypeReference]) then //todo: fix up text
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing string');
  value := lowercase(RemoveAccents(copy(value, 1, INDEX_ENTRY_LENGTH)));
  FEntries.add(key, parent, ndx, 0, '', value, 0, SearchParamTypeString);
end;

function TFhirIndexManager.Link: TFHIRIndexManager;
begin
  result := TFHIRIndexManager (inherited Link);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value1, value2, name: String);
var
  ndx : TFhirIndex;
begin
  if (value1 = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name+' on type '+CODES_TFhirResourceType[aType]);
  if not (ndx.SearchType in [SearchParamTypeString, SearchParamTypeToken, SearchParamTypeDate]) then //todo: fix up text
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing string');

  if ndx.SearchType = SearchParamTypeString then
    value1 := lowercase(RemoveAccents(copy(value1, 1, INDEX_ENTRY_LENGTH)))
  else  if (length(value1) > INDEX_ENTRY_LENGTH) then
    raise exception.create('string too long for indexing: '+value1+ ' ('+inttostr(length(value1))+' chars)');

  if ndx.SearchType = SearchParamTypeString then
    value2 := lowercase(RemoveAccents(copy(value2, 1, INDEX_ENTRY_LENGTH)))
  else if (length(value2) > INDEX_ENTRY_LENGTH) then
    raise exception.create('string too long for indexing: '+value2+ ' ('+inttostr(length(value2))+' chars)');

  FEntries.add(key, parent, ndx, 0, value1, value2, 0, ndx.SearchType);
end;


procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: Boolean; name: String);
begin
  index(aType, key, parent, BooleanToString(value), name);
end;


procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirEnum; system, name: String);
var
  ndx : TFhirIndex;
  concept : integer;
begin
  if (value = nil) or (value.value = '') then
    exit;

  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name+' on type '+CODES_TFhirResourceType[aType]);
  if not (ndx.SearchType in [SearchParamTypeToken]) then //todo: fix up text
    raise Exception.create('Unsuitable index '+name+' of type '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing enumeration on '+CODES_TFHIRResourceType[aType]);
  if (length(value.value) > INDEX_ENTRY_LENGTH) then
     raise exception.create('string too long for indexing: '+value.value+ ' ('+inttostr(length(value.value))+' chars)');
  if system <> '' then
  begin
    concept := TerminologyServer.enterIntoClosure(FSpaces.FDB, CODES_TFhirResourceType[aType]+'.'+name, system, value.value);
    assert(concept <> 0);
  end
  else
    concept := 0;

  FEntries.add(key, parent, ndx, 0, value.value, '', 0, ndx.SearchType, false, concept);
end;


procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirInstant; name: String);
begin
  if (value <> nil) and (value.value <> nil) then
    index(aType, key, parent, asUTCMin(value), asUTCMax(value), name);
end;

procedure TFhirIndexManager.ReconcileIndexes;
var
  i : integer;
begin
  FSpaces.FDB.SQL := 'select * from Indexes';
  FSpaces.FDb.prepare;
  FSpaces.FDb.execute;
  while FSpaces.FDb.FetchNext do
  begin
    for i := 0 to FIndexes.Count - 1 Do
      if SameText(FIndexes[i].Name, FSpaces.FDb.ColStringByName['Name']) then
        FIndexes[i].key := FSpaces.FDb.ColIntegerByName['IndexKey'];

    for i := 0 to FComposites.Count - 1 Do
      if SameText(FComposites[i].Name, FSpaces.FDb.ColStringByName['Name']) then
        FComposites[i].key := FSpaces.FDb.ColIntegerByName['IndexKey'];

    if FSpaces.FDb.ColStringByName['Name'] = NARRATIVE_INDEX_NAME then
      FNarrativeIndex := FSpaces.FDb.ColIntegerByName['IndexKey'];
  end;
  FSpaces.FDb.terminate;
end;

procedure TFhirIndexManager.SetTerminologyServer(const Value: TTerminologyServerStore);
begin
  FTerminologyServer.Free;
  FTerminologyServer := Value;
end;

function TFhirIndexManager.execute(key : integer; id : String; resource : TFhirResource; tags : TFHIRAtomCategoryList) : String;
var
  i : integer;
  entry : TFhirIndexEntry;
begin
  FEntries.clear;
  FEntries.FKeyEvent := FKeyEvent;

  index(resource.ResourceType, key, 0, id, '_id');
  if (resource.languageElement <> nil) then
    index(resource.ResourceType, key, 0, resource.language, '_language');
  FMasterKey := key;
  FSpaces.FDB.ExecSQL('delete from Compartments where ResourceKey in (select ResourceKey from Ids where MasterResourceKey = '+inttostr(key)+')');
  FSpaces.FDB.ExecSQL('delete from IndexEntries where ResourceKey in (select ResourceKey from Ids where MasterResourceKey = '+inttostr(key)+')');
  FSpaces.FDB.ExecSQL('delete from IndexEntries where Target in (select ResourceKey from Ids where MasterResourceKey = '+inttostr(key)+')');
  FSpaces.FDB.ExecSQL('delete from SearchEntries where ResourceKey in (select ResourceKey from Ids where MasterResourceKey = '+inttostr(key)+')');
  FSpaces.FDB.ExecSQL('delete from Ids where MasterResourceKey = '+inttostr(key));
  FPatientCompartments.Clear;

  processCompartmentTags(key, id, tags);
  buildIndexValues(key, id, resource, resource);
  processUnCompartmentTags(key, id, tags);

  if resource is TFhirDomainResource then
  begin
    FSpaces.FDB.SQL := 'insert into indexEntries (EntryKey, IndexKey, ResourceKey, Flag, Extension, Xhtml) values (:k, :i, :r, 1, ''html'', :xb)';
    FSpaces.FDB.prepare;
    FSpaces.FDB.BindInteger('k', FKeyEvent(ktEntries));
    FSpaces.FDB.BindInteger('i', FNarrativeIndex);
    FSpaces.FDB.BindInteger('r', key);
    FSpaces.FDB.BindBlobFromBytes('xb', EncodeXhtml(TFhirDomainResource(resource)));
    FSpaces.FDB.execute;
    FSpaces.FDB.terminate;
  end;

  FSpaces.FDB.SQL := 'insert into indexEntries (EntryKey, IndexKey, ResourceKey, Parent, MasterResourceKey, SpaceKey, Value, Value2, Flag, target, concept) values (:k, :i, :r, :p, :m, :s, :v, :v2, :f, :t, :c)';
  FSpaces.FDB.prepare;
  for i := 0 to FEntries.Count - 1 Do
  begin
    entry := FEntries[i];
    FSpaces.FDB.BindInteger('k', FEntries[i].EntryKey);
    FSpaces.FDB.BindInteger('i', entry.IndexKey);
    FSpaces.FDB.BindInteger('r', entry.key);
    if entry.parent = 0 then
      FSpaces.FDB.BindNull('p')
    else
      FSpaces.FDB.BindInteger('p', entry.parent);
    if entry.key <> key then
      FSpaces.FDB.BindInteger('m', key)
    else
      FSpaces.FDB.BindNull('m');
    if entry.Flag then
      FSpaces.FDB.BindInteger('f', 1)
    else
      FSpaces.FDB.BindInteger('f', 0);
    if entry.concept = 0 then
      FSpaces.FDB.BindNull('c')
    else
      FSpaces.FDB.BindInteger('c', entry.concept);

    if entry.FRefType = 0 then
      FSpaces.FDB.BindNull('s')
    else
      FSpaces.FDB.BindInteger('s', entry.FRefType);
    FSpaces.FDB.BindString('v', entry.FValue1);
    FSpaces.FDB.BindString('v2', entry.FValue2);
    if (entry.Target = 0) or (entry.Target = FMasterKey) then
      FSpaces.FDB.BindNull('t')
    else
      FSpaces.FDB.BindInteger('t', entry.target);
    try
      FSpaces.FDB.execute;
    except
      on e:exception do
        raise Exception.Create('Exception storing values "'+entry.FValue1+'" and "'+entry.FValue2+'": '+e.message);

    end;
  end;
  FSpaces.FDB.terminate;

  result := '';
  if FPatientCompartments.Count > 0 then
  begin
    FSpaces.FDB.SQL := 'insert into Compartments (ResourceCompartmentKey, ResourceKey, MasterResourceKey, CompartmentType, CompartmentKey, Id) values (:pk, :r, :mr, :ct, :ck, :id)';
    FSpaces.FDB.prepare;
    for i := 0 to FPatientCompartments.Count - 1 Do
    begin
      if i > 0 then
        result := result + ', ';
      result := result + ''''+FPatientCompartments[i].id+'''';

      FSpaces.FDB.BindInteger('pk', FKeyEvent(ktCompartment));
      FSpaces.FDB.BindInteger('r', FPatientCompartments[i].key);
      FSpaces.FDB.BindInteger('mr', key);
      FSpaces.FDB.BindInteger('ct', 1);
      FSpaces.FDB.BindString('id', FPatientCompartments[i].id);
      if FPatientCompartments[i].ckey > 0 then
        FSpaces.FDB.BindInteger('ck', FPatientCompartments[i].ckey)
      else
        FSpaces.FDB.BindNull('ck');
      FSpaces.FDB.execute;
    end;
    FSpaces.FDB.terminate;
  end;
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirCoding; name: String);
var
  ndx : TFhirIndex;
  ref : integer;
  concept : integer;
begin
  if (value = nil) or (value.code = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if ndx.SearchType <> SearchParamTypeToken then
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing Coding');
  if (value.system <> '') then
  begin
    ref := FSpaces.ResolveSpace(value.system);
    concept := TerminologyServer.enterIntoClosure(FSpaces.FDB, CODES_TFhirResourceType[aType]+'.'+name, value.system, value.code);
  end
  else
  begin
    ref := 0;
    concept := 0;
  end;

  if (length(value.code) > INDEX_ENTRY_LENGTH) then
    raise exception.create('code too long for indexing: '+value.code);
  if value.display <> '' then
    FEntries.add(key, parent, ndx, ref, value.code, lowercase(RemoveAccents(copy(value.display, 1, INDEX_ENTRY_LENGTH))), 0, ndx.SearchType, false, concept)
  else
    FEntries.add(key, parent, ndx, ref, value.code, '', 0, ndx.SearchType, false, concept);
end;

Function ComparatorPrefix(v : String; c : TFhirQuantityComparator) : String;
begin
  case c of
    QuantityComparatorLessThan : result := '<'+v;
    QuantityComparatorLessOrEquals : result := '<='+v;
    QuantityComparatorGreaterOrEquals : result := '>='+v;
    QuantityComparatorGreaterThan : result := '>'+v;
  else
    result := v;
  end;
end;

procedure TFhirIndexManager.GetBoundaries(value : String; comparator: TFhirQuantityComparator; var low, high : String);
var
  dec : TSmartDecimal;
begin
  dec := FTerminologyServer.Ucum.Model.Context.Value(value);
  case comparator of
    QuantityComparatorNull :
      begin
      low := dec.lowerBound.AsDecimal;
      high := dec.upperBound.AsDecimal;
      end;
    QuantityComparatorLessThan :
      begin
      low := '-9999999999999999999999999999999999999999';
      high := dec.upperBound.AsDecimal;
      end;
    QuantityComparatorLessOrEquals :
      begin
      low := '-9999999999999999999999999999999999999999';
      high := dec.immediateLowerBound.AsDecimal;
      end;
    QuantityComparatorGreaterOrEquals :
      begin
      low := dec.lowerBound.AsDecimal;
      high := '9999999999999999999999999999999999999999';
      end;
    QuantityComparatorGreaterThan :
      begin
      low := dec.immediateUpperBound.AsDecimal;
      high := '9999999999999999999999999999999999999999';
      end;
  end;
end;


function TFhirIndexManager.GetComposite(types: TFhirResourceTypeSet; name: String; var otypes: TFhirResourceTypeSet): TFhirComposite;
var
  i : integer;
begin
  oTypes := types;

  i := 0;
  result := nil;
  while (i < FComposites.Count) do
  begin
    if SameText(FComposites.item[i].name, name) and (FComposites.item[i].FResourceType in types) then
      if result = nil then
      begin
        result := FComposites.item[i];
        oTypes := [FComposites.item[i].FResourceType];
      end
      else
        raise Exception.Create('Ambiguous composite reference "'+name+'"');
    inc(i);
  end;
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value : TFhirQuantity; name : String);
var
  ndx : TFhirIndex;
  v1, v2 : String;
  ref : integer;
  specified, canonical : TUcumPair;
  context : TSmartDecimalContext;
begin
  if value = nil then
    exit;

  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join: "'+name+'"');
  if not (ndx.SearchType in [SearchParamTypeToken, SearchParamTypeNumber, SearchParamTypeQuantity]) then
    raise Exception.create('Unsuitable index "'+name+'" '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing quantity');

  GetBoundaries(value.value, value.comparator, v1, v2);

  if (length(v1) > INDEX_ENTRY_LENGTH) then
      raise exception.create('quantity.value too long for indexing: "'+v1+ '" ('+inttostr(length(v1))+' chars, limit '+inttostr(INDEX_ENTRY_LENGTH)+')');
  if (length(v2) > INDEX_ENTRY_LENGTH) then
      raise exception.create('quantity.value too long for indexing: "'+v2+ '" ('+inttostr(length(v2))+' chars, limit '+inttostr(INDEX_ENTRY_LENGTH)+')');
  ref := FSpaces.ResolveSpace(value.units);
  FEntries.add(key, parent, ndx, ref, v1, v2, 0, ndx.SearchType);
  if value.system <> '' then
  begin
    ref := FSpaces.ResolveSpace(value.system+'#'+value.code);
    FEntries.add(key, parent, ndx, ref, v1, v2, 0, ndx.SearchType);
  end;

  // ok, if there's a ucum code:
  if (value.code <> '') and (value.system = 'http://unitsofmeasure.org') then
  begin
    context := TSmartDecimalContext.Create;
    specified := TUcumPair.create;
    try
      specified.Value := context.Value(value.value).Link;
      specified.UnitCode := value.code;
      canonical := FTerminologyServer.Ucum.getCanonicalForm(specified);
      try
        GetBoundaries(canonical.Value.AsString, value.comparator, v1, v2);
        if (length(v1) > INDEX_ENTRY_LENGTH) then
          raise exception.create('quantity.value too long for indexing: "'+v1+ '" ('+inttostr(length(v1))+' chars, limit '+inttostr(INDEX_ENTRY_LENGTH)+')');
        if (length(v2) > INDEX_ENTRY_LENGTH) then
          raise exception.create('quantity.value too long for indexing: "'+v2+ '" ('+inttostr(length(v2))+' chars, limit '+inttostr(INDEX_ENTRY_LENGTH)+')');
        ref := FSpaces.ResolveSpace('urn:ucum-canonical#'+canonical.UnitCode);
        FEntries.add(key, parent, ndx, ref, v1, v2, 0, ndx.SearchType, true);
      finally
        canonical.free;
        context.Free;
      end;
    finally
      specified.free;
    end;
  end;
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value : TFhirPeriod; name : String);
begin
  if (value <> nil) then
    index(aType, key, parent, asUTCMin(value), asUTCMax(value), name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value : TFhirTiming; name : String);
begin
  if (value <> nil) then
    index(aType, key, parent, asUTCMin(value), asUTCMax(value), name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirDateTime; name: String);
begin
  if (value <> nil) and (value.value <> nil) then
    index(aType, key, parent, asUTCMin(value), asUTCMax(value), name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; min, max : TDateTime; name: String);
var
  ndx : TFhirIndex;
begin
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType = SearchParamTypeDate) then
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing date');
  FEntries.add(key, parent, ndx, 0, HL7DateToString(min, 'yyyymmddhhnnss', false), HL7DateToString(max, 'yyyymmddhhnnss', false), 0, ndx.SearchType);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirIdentifier; name: String);
var
  ndx : TFhirIndex;
  ref : integer;
begin
  if (value = nil) or (value.value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType in [SearchParamTypeToken]) then
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing Identifier');
  ref := 0;
  if (value.system <> '') then
    ref := FSpaces.ResolveSpace(value.system);
  if (length(value.value) > INDEX_ENTRY_LENGTH) then
    raise exception.create('id too long for indexing: '+value.value);
  FEntries.add(key, parent, ndx, ref, value.value, '', 0, ndx.SearchType);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirAddress; name: String);
var
  i : integer;
begin
  if (value = nil) then
    exit;
  for i := 0 to value.lineList.count - 1 do
    index(aType, key, parent, value.lineList[i], name);
  index(aType, key, parent, value.cityElement, name);
  index(aType, key, parent, value.stateElement, name);
  index(aType, key, parent, value.countryElement, name);
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirContactPoint; name: String);
var
  ndx : TFhirIndex;
  ref : integer;
begin
  if (value = nil) or (value.value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType in [SearchParamTypeToken, SearchParamTypeString]) then
    raise Exception.create('Unsuitable index '+name+':'+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing Contact on '+CODES_TFhirResourceType[aType]);
  ref := 0;
  if (value.systemElement <> nil) and (value.systemElement.value <> '') then
    ref := FSpaces.ResolveSpace(value.systemElement.value);
  if (length(value.value) > INDEX_ENTRY_LENGTH) then
    raise exception.create('contact value too long for indexing: '+value.value);
  FEntries.add(key, parent, ndx, ref, value.value, '', 0, ndx.SearchType);
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirIdentifierList; name: String);
var
  i : integer;
begin
  if (value <> nil) then
    for i := 0 to value.Count - 1 do
      index(atype, key, parent, value[i], name);
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirCodingList; name: String);
var
  i : integer;
begin
  if (value <> nil) then
    for i := 0 to value.Count - 1 do
      index(atype, key, parent, value[i], name);
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirCodeableConceptList; name: String);
var
  i : integer;
begin
  if (value <> nil) then
    for i := 0 to value.Count - 1 do
      index(atype, key, parent, value[i], name);
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirSampledData; name: String);
begin
 // todo
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirRatio; name: String);
begin
  // don't have a clue what to do here
end;

procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirHumanName; name, phoneticName: String);
var
  i : integer;
begin
  if (value = nil) then
    exit;
  for i := 0 to value.familyList.count - 1 do
    index(aType, key, parent, value.familyList[i], name);
  for i := 0 to value.givenList.count - 1 do
    index(aType, key, parent, value.givenList[i], name);
  for i := 0 to value.prefixList.count - 1 do
    index(aType, key, parent, value.prefixList[i], name);
  for i := 0 to value.suffixList.count - 1 do
    index(aType, key, parent, value.suffixList[i], name);
  if phoneticName <> '' then
  begin
    for i := 0 to value.familyList.count - 1 do
      index(aType, key, parent, EncodeNYSIIS(value.familyList[i].value), phoneticName);
    for i := 0 to value.givenList.count - 1 do
      index(aType, key, parent, EncodeNYSIIS(value.givenList[i].value), phoneticName);
    for i := 0 to value.prefixList.count - 1 do
      index(aType, key, parent, EncodeNYSIIS(value.prefixList[i].value), phoneticName);
    for i := 0 to value.suffixList.count - 1 do
      index(aType, key, parent, EncodeNYSIIS(value.suffixList[i].value), phoneticName);
  end;
end;

{
procedure TFhirIndexManager.index(aType : TFhirResourceType; key, parent : integer; value: TFhirDecimal; name: String);
var
  ndx : TFhirIndex;
begin
  if (value = nil) or (value.value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType in [SearchParamTypeString, SearchParamTypeToken]) then
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing decimal');
  FEntries.add(key, ndx, 0, value.value, '', 0, ndx.SearchType);
end;
}

// todo: this doesn't yet handle version references
function isLocalTypeReference(url : String; var type_, id : String) : boolean;
var
  i : TFhirResourceType;
begin
  result := false;
  for i := Low(CODES_TFhirResourceType) to High(CODES_TFhirResourceType) do
    if url.StartsWith(CODES_TFhirResourceType[i]+'/') and IsId(url.Substring(url.IndexOf('/')+1)) then
      result := true;
  if result then
    StringSplit(url, '/', type_, id);
end;

function sumContainedResources(resource : TFhirDomainResource) : string;
var
  i: Integer;
begin
  result := '';
  for i := 0 to resource.containedList.Count - 1 do
    result := result + ',' + resource.containedList[i].xmlId;
  delete(result, 1, 1);
end;

procedure TFhirIndexManager.index(context : TFhirResource; aType : TFhirResourceType; key, parent : integer; value: TFhirReference; name: String);
var
  ndx : TFhirIndex;
  ref, i : integer;
  target : integer;
  type_, id : String;
  contained : TFhirResource;
  url : String;
begin
  if (value = nil) then
    exit;
  if (value.reference = '') and (value.display <> '') then
  begin
    index(aType, key, parent, value.displayElement, name);
    exit;
  end;
  if (value.reference = '') then
    exit;

  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) and (name = 'patient') then
    ndx := FIndexes.getByName(aType, 'subject');
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes = []) then
    raise Exception.create('Attempt to index a resource join in an index ('+CODES_TFhirResourceType[aType]+'/'+name+') that is a not a join (has no target types)');
  if ndx.SearchType <> SearchParamTypeReference then
    raise Exception.create('Unsuitable index '+name+' '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing Contact');

  if (length(value.reference) > INDEX_ENTRY_LENGTH) then
    raise exception.create('resource url too long for indexing: '+value.reference);

 {
  ! if the value has a value, then we need to index the value, even though we don't actually have it as a resource
  ! what we do is construct it with a fictional GUID id and index that
  }

  target := 0;
  ref := 0;

  if StringStartsWith(value.reference, '#') then
  begin
    if context is TFhirDomainResource then
      contained := FindContainedResource(TFhirDomainResource(context), value)
    else
      raise exception.create('Reference to contained resource found in a resource that does not have contained resources"');
    if contained = nil then
      raise exception.create('No contained resource found in resource for "'+value.reference+'", list from '+CODES_TFhirResourceType[context.ResourceType]+' = "'+sumContainedResources(TFhirDomainResource(context))+'"');

    ref := FSpaces.ResolveSpace(CODES_TFhirResourceType[contained.ResourceType]);
    if (contained = nil) then
      raise exception.create('Unable to find internal reference to contained resource: "'+value.reference+'", list = '+sumContainedResources(TFhirDomainResource(context)));
    id := FHIRGuidToString(CreateGuid);
    target := FKeyEvent(ktResource); //FSpaces.FDB.CountSQL('select Max(ResourceKey) from Ids') + 1;
    FSpaces.FDB.SQL := 'insert into Ids (ResourceKey, ResourceTypeKey, Id, MostRecent, MasterResourceKey) values (:k, :r, :i, null, '+inttostr(FMasterKey)+')';
    FSpaces.FDB.Prepare;
    FSpaces.FDB.BindInteger('k', target);
    FSpaces.FDB.BindInteger('r', ref);
    FSpaces.FDB.BindString('i', id);
    FSpaces.FDB.Execute;
    FSpaces.FDB.Terminate;
    buildIndexValues(target, '', context, contained);
  end
  else
  begin
    url := value.reference;
    for i := 0 to FBases.Count -1 do
    begin
      if StringStartsWith(url, FBases[i]+'/') then
        url := copy(Url, length(FBases[i])+2, $FFFF);
    end;
    if isLocalTypeReference(url, type_, id) then
    begin
      ref := FSpaces.ResolveSpace(type_);
      FSpaces.FDB.sql := 'Select ResourceKey from Ids as i, Types as t where i.ResourceTypeKey = t.ResourceTypeKey and ResourceName = :t and Id = :id';
      FSpaces.FDB.Prepare;
      FSpaces.FDB.BindString('t', type_);
      FSpaces.FDB.BindString('id', id);
      FSpaces.FDB.Execute;
      if FSpaces.FDB.FetchNext then
        target := FSpaces.FDB.ColIntegerByName['ResourceKey']; // otherwise we try and link it up if we ever see the resource that this refers to
      FSpaces.FDB.Terminate;
    end;
  end;

  FEntries.add(key, parent, ndx, ref, id, '', target, ndx.SearchType);
end;

function TFhirIndexManager.GetKeyByName(types: TFhirResourceTypeSet; name: String): integer;
var
  i : integer;
begin
  result := 0;
  for i := 0 to FIndexes.Count - 1 Do
    if FIndexes[i].Name = name then
    begin
      result := FIndexes[i].Key;
      exit;
    end;
end;

function TFhirIndexManager.GetTargetsByName(types: TFhirResourceTypeSet; name: String): TFhirResourceTypeSet;
var
  i : integer;
begin
  result := [];
  for i := 0 to FIndexes.Count - 1 Do
    if SameText(FIndexes[i].Name, name) and (FIndexes[i].ResourceType in types) then
      result := result + FIndexes[i].TargetTypes;
end;

function TFhirIndexManager.GetTypeByName(types: TFhirResourceTypeSet; name: String): TFhirSearchParamType;
var
  i : integer;
begin
  result := SearchParamTypeNull;
  for i := 0 to FIndexes.Count - 1 Do
    if SameText(FIndexes[i].Name, name) and ((FIndexes[i].ResourceType in types) or (types = [frtNull])) then
      if (result <> SearchParamTypeNull) and (result <> FIndexes[i].FSearchType) And ((FIndexes[i].FSearchType in [SearchParamTypeDate, SearchParamTypeToken]) or (result in [SearchParamTypeDate, SearchParamTypeToken])) then
        raise Exception.create('Chained Parameters cross resource joins that create disparate index handling requirements')
      else
        result := FIndexes[i].FSearchType;
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsEncounter : Array[TSearchParamsEncounter] of TSearchParamsEncounter = ( spEncounter__id, spEncounter__Language, spEncounter_Date, spEncounter_Identifier, spEncounter_Indication, spEncounter_Length, spEncounter_Location, spEncounter_Location_period, spEncounter_Status, spEncounter_Subject);
  {$ELSE}
  CHECK_TSearchParamsEncounter : Array[TSearchParamsEncounter] of TSearchParamsEncounter = ( spEncounter__id, spEncounter__language, spEncounter__lastUpdated, spEncounter__profile, spEncounter__security, spEncounter__tag,
     spEncounter_Date, spEncounter_Episodeofcare, spEncounter_Identifier, spEncounter_Indication, spEncounter_Length, spEncounter_Location, spEncounter_Location_period, spEncounter_Part_of, spEncounter_Participant_type, spEncounter_Patient, spEncounter_Special_arrangement, spEncounter_Status, spEncounter_Type);

  {$ENDIF}

procedure TFhirIndexManager.buildIndexesEncounter;
var
  a : TSearchParamsEncounter;
begin
  for a := low(TSearchParamsEncounter) to high(TSearchParamsEncounter) do
  begin
    assert(CHECK_TSearchParamsEncounter[a] = a);
    indexes.add(frtEncounter, CODES_TSearchParamsEncounter[a], DESC_TSearchParamsEncounter[a], TYPES_TSearchParamsEncounter[a], TARGETS_TSearchParamsEncounter[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEncounter(key: integer; id : String; context : TFhirResource; resource: TFhirEncounter);
var
  i : integer;
begin
  {$IFDEF FHIR-DSTU}
  index(context, frtEncounter, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  index(context, frtEncounter, key, 0, resource.indicationElement, 'indication');
  {$ELSE}
  index(context, frtEncounter, key, 0, resource.patient, 'patient');
  index(frtEncounter, key, 0, resource.type_List, 'type');
  for i := 0 to resource.participantList.count - 1 do
    index(frtEncounter, key, 0, resource.participantList[i].type_List, 'participant-type');
  index(context, frtEncounter, key, 0, resource.partOf, 'part-of');
  index(context, frtEncounter, key, 0, resource.episodeOfCare, 'episodeofcare');
  if resource.hospitalization <> nil then
    index(frtEncounter, key, 0, resource.hospitalization.specialArrangementList, 'special-arrangement');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.indicationList.count - 1 do
    index(context, frtEncounter, key, 0, resource.indicationList[i], 'indication');
  {$ENDIF}
  index(frtEncounter, key, 0, resource.statusElement, 'http://hl7.org/fhir/encounter-state', 'status');
  index(frtEncounter, key, 0, resource.periodElement, 'date');
  index(frtEncounter, key, 0, resource.lengthElement, 'length');
  for i := 0 to resource.identifierList.count - 1 do
    index(frtEncounter, key, 0, resource.identifierList[i], 'identifier');
  for i := 0 to resource.locationList.count - 1 do
  begin
    index(context, frtEncounter, key, 0, resource.locationList[i].locationElement, 'location');
    index(frtEncounter, key, 0, resource.locationList[i].periodElement, 'location-period');
  end;
end;

Const
{$IFNDEF FHIR-DSTU}
  CHECK_TSearchParamsLocation : Array[TSearchParamsLocation] of TSearchParamsLocation = ( spLocation__id, spLocation__Language, spLocation__lastUpdated, spLocation__profile, spLocation__security, spLocation__tag,
     spLocation_Address, spLocation_Identifier, spLocation_Name, spLocation_Near, spLocation_Near_distance, spLocation_Organization, spLocation_Partof, spLocation_Status, spLocation_Type);
{$ELSE}
  CHECK_TSearchParamsLocation : Array[TSearchParamsLocation] of TSearchParamsLocation = ( spLocation__id, spLocation__language, spLocation_Address, spLocation_Identifier, spLocation_Name, spLocation_Near, spLocation_Near_distance, spLocation_Partof, spLocation_Status, spLocation_Type);
{$ENDIF}


procedure TFhirIndexManager.buildIndexesLocation;
var
  a : TSearchParamsLocation;
begin
  for a := low(TSearchParamsLocation) to high(TSearchParamsLocation) do
  begin
    assert(CHECK_TSearchParamsLocation[a] = a);
    indexes.add(frtLocation, CODES_TSearchParamsLocation[a], DESC_TSearchParamsLocation[a], TYPES_TSearchParamsLocation[a], TARGETS_TSearchParamsLocation[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesLocation(key: integer; id : String; context : TFhirResource; resource: TFhirLocation);
{$IFNDEF FHIR-DSTU}
var
  i : integer;
{$ENDIF}
begin
  index(frtLocation, key, 0, resource.addressElement, 'address');
  index(frtLocation, key, 0, resource.NameElement, 'name');
  index(frtLocation, key, 0, resource.statusElement, 'http://hl7.org/fhir/location-status', 'status');
  index(frtLocation, key, 0, resource.type_Element, 'type');
  {$IFDEF FHIR-DSTU}
  index(frtLocation, key, 0, resource.identifier, 'identifier');
  {$ELSE}
  for i := 0 to resource.identifierList.Count - 1 do
    index(frtLocation, key, 0, resource.identifierList, 'identifier');
  index(context, frtLocation, key, 0, resource.managingOrganizationElement, 'organization');
  {$ENDIF}
  index(context, frtLocation, key, 0, resource.partOf, 'partof');
  if resource.position <> nil then
  begin
    if (resource.position.longitude <> '') and (resource.position.latitude <> '') then
      index(frtLocation, key, 0, resource.position.longitude, resource.position.latitude, 'near');
  end
//    spLocation_Near_distance, {@enum.value spLocation_Near_distance A distance quantity to limit the near search to locations within a specific distance }
end;

{$IFDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsQuery : Array[TSearchParamsQuery] of TSearchParamsQuery = ( spQuery__id, spQuery__Language, spQuery_Identifier, spQuery_Response);

procedure TFhirIndexManager.buildIndexesQuery;
var
  a : TSearchParamsQuery;
begin
  for a := low(TSearchParamsQuery) to high(TSearchParamsQuery) do
  begin
    assert(CHECK_TSearchParamsQuery[a] = a);
    indexes.add(frtQuery, CODES_TSearchParamsQuery[a], DESC_TSearchParamsQuery[a], TYPES_TSearchParamsQuery[a], TARGETS_TSearchParamsQuery[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesQuery(key: integer; id : String; context : TFhirResource; resource: TFhirQuery);
begin
  index(frtQuery, key, 0, resource.identifierElement, 'identifier');
  if resource.response <> nil then
    index(frtQuery, key, 0, resource.response.identifierElement, 'response');
end;
{$ENDIF}



Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsDocumentReference : Array[TSearchParamsDocumentReference] of TSearchParamsDocumentReference = ( spDocumentReference__id, spDocumentReference__Language, spDocumentReference_Authenticator, spDocumentReference_Author, spDocumentReference_Class, spDocumentReference_Confidentiality, spDocumentReference_Created, spDocumentReference_Custodian, spDocumentReference_Description, spDocumentReference_Event, spDocumentReference_Facility, spDocumentReference_Format, spDocumentReference_Identifier, spDocumentReference_Indexed, spDocumentReference_Language, spDocumentReference_Location, spDocumentReference_Period, spDocumentReference_Relatesto, spDocumentReference_Relation, spDocumentReference_Relationship, spDocumentReference_Size, spDocumentReference_Status, spDocumentReference_Subject, spDocumentReference_Type);
  {$ELSE}
  CHECK_TSearchParamsDocumentReference : Array[TSearchParamsDocumentReference] of TSearchParamsDocumentReference = ( spDocumentReference__id, spDocumentReference__Language, spDocumentReference__LastUpdated, spDocumentReference__profile, spDocumentReference__security, spDocumentReference__tag,
     spDocumentReference_Authenticator, spDocumentReference_Author, spDocumentReference_Class, spDocumentReference_Confidentiality, spDocumentReference_Created, spDocumentReference_Custodian, spDocumentReference_Description, spDocumentReference_Event, spDocumentReference_Facility, spDocumentReference_Format, spDocumentReference_Identifier, spDocumentReference_Indexed, spDocumentReference_Language, spDocumentReference_Location, spDocumentReference_Patient, spDocumentReference_Period, spDocumentReference_Relatesto, spDocumentReference_Relation, spDocumentReference_Relationship, spDocumentReference_Size, spDocumentReference_Status, spDocumentReference_Subject, spDocumentReference_Type);
  {$ENDIF}




procedure TFhirIndexManager.buildIndexesDocumentReference;
var
  a : TSearchParamsDocumentReference;
begin
  for a := low(TSearchParamsDocumentReference) to high(TSearchParamsDocumentReference) do
  begin
    assert(CHECK_TSearchParamsDocumentReference[a] = a);
    indexes.add(frtDocumentReference, CODES_TSearchParamsDocumentReference[a], DESC_TSearchParamsDocumentReference[a], TYPES_TSearchParamsDocumentReference[a], TARGETS_TSearchParamsDocumentReference[a]);
  end;
  composites.add(frtDocumentReference, 'relatesTo', ['code', 'relation', 'target', 'relatesTo']);
end;

procedure TFhirIndexManager.BuildIndexValuesDocumentReference(key: integer;id : String; context : TFhirResource; resource: TFhirDocumentReference);
var
  i, p : integer;
begin
  index(context, frtDocumentReference, key, 0, resource.authenticator, 'authenticator');
  for i := 0 to resource.authorList.count - 1 do
    index(context, frtDocumentReference, key, 0, resource.authorList[i], 'author');
  for i := 0 to resource.confidentialityList.count - 1 do
    index(frtDocumentReference, key, 0, resource.confidentialityList[i], 'confidentiality');
  index(frtDocumentReference, key, 0, resource.createdElement, 'created');
  index(context, frtDocumentReference, key, 0, resource.custodian, 'custodian');
  index(frtDocumentReference, key, 0, resource.descriptionElement, 'description');
  if resource.context <> nil then
  begin
    for i := 0 to resource.context.eventList.count - 1 do
      index(frtDocumentReference, key, 0, resource.context.eventList[i], 'event');
    index(frtDocumentReference, key, 0, resource.context.facilityType, 'facility');
    index(frtDocumentReference, key, 0, resource.context.period, 'period');
  end;
  for i := 0 to resource.formatList.count - 1 do
    index(frtDocumentReference, key, 0, resource.formatList[i], 'format');
  index(frtDocumentReference, key, 0, resource.masterIdentifier, 'identifier');
  for i := 0 to resource.identifierList.count - 1 do
    index(frtDocumentReference, key, 0, resource.identifierList[i], 'identifier');
  index(frtDocumentReference, key, 0, resource.indexedElement, 'indexed');
  index(frtDocumentReference, key, 0, resource.primaryLanguageElement, 'language');
  index(frtDocumentReference, key, 0, resource.locationElement, 'location');
  index(frtDocumentReference, key, 0, resource.sizeElement, 'size');
  index(frtDocumentReference, key, 0, resource.statusElement, 'http://hl7.org/fhir/document-reference-status', 'status');
  index(context, frtDocumentReference, key, 0, resource.subject, 'subject');
  index(context, frtDocumentReference, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  for i := 0 to resource.relatesToList.Count - 1 do
  begin
    p := index(frtDocumentReference, key, 0, 'relatesTo');
    index(context, frtDocumentReference, key, p, resource.relatesToList[i].target, 'relatesTo');
    index(frtDocumentReference, key, p, resource.relatesToList[i].codeElement, 'http://hl7.org/fhir/document-relationship-type', 'relation');
  end;
  index(frtDocumentReference, key, 0, resource.type_, 'type');
  index(frtDocumentReference, key, 0, resource.class_, 'class');
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsDocumentManifest : Array[TSearchParamsDocumentManifest] of TSearchParamsDocumentManifest = ( spDocumentManifest__id, spDocumentManifest__Language, spDocumentManifest_Author, spDocumentManifest_Confidentiality, spDocumentManifest_Content, spDocumentManifest_Created, spDocumentManifest_Description, spDocumentManifest_Identifier, spDocumentManifest_Recipient, spDocumentManifest_Status, spDocumentManifest_Subject, spDocumentManifest_Supersedes, spDocumentManifest_Type);
  {$ELSE}
  CHECK_TSearchParamsDocumentManifest : Array[TSearchParamsDocumentManifest] of TSearchParamsDocumentManifest = ( spDocumentManifest__id, spDocumentManifest__language, spDocumentManifest__lastUpdated, spDocumentManifest__profile, spDocumentManifest__security, spDocumentManifest__tag,
     spDocumentManifest_Author, spDocumentManifest_Confidentiality, spDocumentManifest_Content, spDocumentManifest_Created, spDocumentManifest_Description, spDocumentManifest_Identifier, spDocumentManifest_Patient, spDocumentManifest_Recipient, spDocumentManifest_Status, spDocumentManifest_Subject, spDocumentManifest_Supersedes, spDocumentManifest_Type);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesDocumentManifest;
var
  a : TSearchParamsDocumentManifest;
begin
  for a := low(TSearchParamsDocumentManifest) to high(TSearchParamsDocumentManifest) do
  begin
    assert(CHECK_TSearchParamsDocumentManifest[a] = a);
    indexes.add(frtDocumentManifest, CODES_TSearchParamsDocumentManifest[a], DESC_TSearchParamsDocumentManifest[a], TYPES_TSearchParamsDocumentManifest[a], TARGETS_TSearchParamsDocumentManifest[a]);
  end;
end;

procedure TFhirIndexManager.BuildIndexValuesDocumentManifest(key: integer;id : String; context : TFhirResource; resource: TFhirDocumentManifest);
var
  i : integer;
begin
  for i := 0 to resource.authorList.count - 1 do
    index(context, frtDocumentManifest, key, 0, resource.authorList[i], 'author');
  index(frtDocumentManifest, key, 0, resource.confidentiality, 'confidentiality');
  index(frtDocumentManifest, key, 0, resource.createdElement, 'created');
  index(frtDocumentManifest, key, 0, resource.descriptionElement, 'description');
  index(frtDocumentManifest, key, 0, resource.masterIdentifier, 'identifier');
  for i := 0 to resource.identifierList.count - 1 do
    index(frtDocumentManifest, key, 0, resource.identifierList[i], 'identifier');
  index(frtDocumentManifest, key, 0, resource.statusElement, 'http://hl7.org/fhir/document-reference-status', 'status');
  for i := 0 to resource.subjectList.count - 1 do
  begin
    index(context, frtDocumentManifest, key, 0, resource.subjectList[i], 'subject');
    index(context, frtDocumentManifest, key, 0, resource.subjectList[i], 'patient');
  end;
  index(context, frtDocumentManifest, key, 0, resource.supercedes, 'supercedes');
  index(frtDocumentManifest, key, 0, resource.type_, 'type');
  for i := 0 to resource.recipientList.count - 1 do
    index(context, frtDocumentManifest, key, 0, resource.recipientList[i], 'recipient');
  for i := 0 to resource.contentList.count - 1 do
    index(context, frtDocumentManifest, key, 0, resource.contentList[i], 'content');
end;

{
procedure TFhirIndexManager.index(aType: TFhirResourceType; key: integer; value: TFhirEnumList; name: String);
var
  i : integer;
begin
  for i := 0 to value.count - 1 do
    index(aType, key, value[i], name);
end;
}

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirInteger; name: String);
var
  ndx : TFhirIndex;
begin
  if (value = nil) or (value.value = '') then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType in [SearchParamTypeString, SearchParamTypeNumber, SearchParamTypeToken]) then
    raise Exception.create('Unsuitable index '+name+' : '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing integer');
  FEntries.add(key, parent, ndx, 0, value.value, '', 0, ndx.SearchType);
end;

{$IFDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsAdverseReaction : Array[TSearchParamsAdverseReaction] of TSearchParamsAdverseReaction = ( spAdverseReaction__id, spAdverseReaction__Language, spAdverseReaction_Date, spAdverseReaction_Subject, spAdverseReaction_Substance, spAdverseReaction_Symptom);

procedure TFhirIndexManager.buildIndexesAdverseReaction;
var
  a : TSearchParamsAdverseReaction;
begin
  for a := low(TSearchParamsAdverseReaction) to high(TSearchParamsAdverseReaction) do
  begin
    assert(CHECK_TSearchParamsAdverseReaction[a] = a);
    indexes.add(frtAdverseReaction, CODES_TSearchParamsAdverseReaction[a], DESC_TSearchParamsAdverseReaction[a], TYPES_TSearchParamsAdverseReaction[a], TARGETS_TSearchParamsAdverseReaction[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesAdverseReaction(key: integer; id : String; context : TFhirResource; resource: TFhirAdverseReaction);
var
  i : integer;
begin
  index(frtAdverseReaction, key, 0, resource.dateElement, 'date');
  index(context, frtAdverseReaction, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
//  index(frtAdverseReaction, key, 0, resource, resource.substance, 'substance');
  for i := 0 to resource.symptomList.count - 1 do
    index(frtAdverseReaction, key, 0, resource.symptomList[i].code, 'symptom');
end;
{$ENDIF}

{$IFNDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsBundle : Array[TSearchParamsBundle] of TSearchParamsBundle = ( spBundle__id, spBundle__language, spBundle__lastUpdated, spBundle__profile, spBundle__security, spBundle__tag,
       spBundle_Composition, spBundle_Message, spBundle_Type);


procedure TFhirIndexManager.buildIndexesBundle;
var
  a : TSearchParamsBundle;
begin
  for a := low(TSearchParamsBundle) to high(TSearchParamsBundle) do
  begin
    assert(CHECK_TSearchParamsBundle[a] = a);
    indexes.add(frtBundle, CODES_TSearchParamsBundle[a], DESC_TSearchParamsBundle[a], TYPES_TSearchParamsBundle[a], TARGETS_TSearchParamsBundle[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesBundle(key: integer; id : String; context : TFhirResource; resource: TFhirBundle);
begin
  index(frtBundle, key, 0, resource.type_Element, 'http://hl7.org/fhir/bundle-type', 'type');
  // todo:
//    spBundle_Composition, {@enum.value "composition" spBundle_Composition The first resource in the bundle, if the bundle type is "document" - this is a composition, and this parameter provides access to searches it's contents }
//    spBundle_Message, {@enum.value "message" spBundle_Message The first resource in the bundle, if the bundle type is "message" - this is a message header, and this parameter provides access to search it's contents }
end;

{$ENDIF}

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsAlert : Array[TSearchParamsAlert] of TSearchParamsAlert = ( spAlert__id, spAlert__Language, spAlert_Subject);
  {$ELSE}
  CHECK_TSearchParamsAlert : Array[TSearchParamsAlert] of TSearchParamsAlert = ( spAlert__id, spAlert__language, spAlert__lastUpdated, spAlert__profile, spAlert__security, spAlert__tag,
     spAlert_Patient, spAlert_Subject);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesAlert;
var
  a : TSearchParamsAlert;
begin
  for a := low(TSearchParamsAlert) to high(TSearchParamsAlert) do
  begin
    assert(CHECK_TSearchParamsAlert[a] = a);
    indexes.add(frtAlert, CODES_TSearchParamsAlert[a], DESC_TSearchParamsAlert[a], TYPES_TSearchParamsAlert[a], TARGETS_TSearchParamsAlert[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesAlert(key: integer; id : String; context : TFhirResource; resource: TFhirAlert);
begin
  index(context, frtAlert, key, 0, resource.subject, 'subject');
  index(context, frtAlert, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsAllergyIntolerance : Array[TSearchParamsAllergyIntolerance] of TSearchParamsAllergyIntolerance = ( spAllergyIntolerance__id, spAllergyIntolerance__Language, spAllergyIntolerance_Date, spAllergyIntolerance_Recorder, spAllergyIntolerance_Status, spAllergyIntolerance_Subject, spAllergyIntolerance_Substance, spAllergyIntolerance_Type);
  {$ELSE}
  CHECK_TSearchParamsAllergyIntolerance : Array[TSearchParamsAllergyIntolerance] of TSearchParamsAllergyIntolerance = ( spAllergyIntolerance__id, spAllergyIntolerance__language, spAllergyIntolerance__lastUpdated, spAllergyIntolerance__profile, spAllergyIntolerance__security, spAllergyIntolerance__tag,
     spAllergyIntolerance_Category, spAllergyIntolerance_Criticality, spAllergyIntolerance_Date, spAllergyIntolerance_Duration, spAllergyIntolerance_Identifier, spAllergyIntolerance_Last_date, spAllergyIntolerance_Manifestation, spAllergyIntolerance_Onset, spAllergyIntolerance_Patient, spAllergyIntolerance_Recorder, spAllergyIntolerance_Route, spAllergyIntolerance_Severity, spAllergyIntolerance_Status, spAllergyIntolerance_Subject, spAllergyIntolerance_Substance, spAllergyIntolerance_Type);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesAllergyIntolerance;
var
  a : TSearchParamsAllergyIntolerance;
begin
  for a := low(TSearchParamsAllergyIntolerance) to high(TSearchParamsAllergyIntolerance) do
  begin
    assert(CHECK_TSearchParamsAllergyIntolerance[a] = a);
    indexes.add(frtAllergyIntolerance, CODES_TSearchParamsAllergyIntolerance[a], DESC_TSearchParamsAllergyIntolerance[a], TYPES_TSearchParamsAllergyIntolerance[a], TARGETS_TSearchParamsAllergyIntolerance[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesAllergyIntolerance(key: integer; id : String; context : TFhirResource; resource: TFhirAllergyIntolerance);
{$IFDEF FHIR-DSTU}
begin
  index(frtAllergyIntolerance, key, 0, resource.recordedDateElement, 'date');
  index(frtAllergyIntolerance, key, 0, resource.statusElement, 'http://hl7.org/fhir/sensitivitystatus', 'status');
  index(context, frtAllergyIntolerance, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  index(context, frtAllergyIntolerance, key, 0, resource.recorder, 'recorder');
  index(context, frtAllergyIntolerance, key, 0, resource.substance, 'substance');
  index(frtAllergyIntolerance, key, 0, resource.sensitivityTypeElement, 'http://hl7.org/fhir/sensitivitytype', 'type');
end;
{$ELSE}
var
  i : integer;
begin
  index(frtAllergyIntolerance, key, 0, resource.categoryElement, 'http://hl7.org/fhir/reaction-risk-category',  'category');
  index(frtAllergyIntolerance, key, 0, resource.criticalityElement, 'http://hl7.org/fhir/reaction-risk-criticality', 'criticality');
  index(frtAllergyIntolerance, key, 0, resource.recordedDateElement, 'date');
  index(frtAllergyIntolerance, key, 0, resource.identifierList, 'identifier');
  index(context, frtAllergyIntolerance, key, 0, resource.recorderElement, 'recorder');
  index(frtAllergyIntolerance, key, 0, resource.lastOccurenceElement, 'last-date');
  index(frtAllergyIntolerance, key, 0, resource.statusElement, 'http://hl7.org/fhir/reaction-risk-status', 'status');
  index(frtAllergyIntolerance, key, 0, resource.type_Element, 'http://hl7.org/fhir/reaction-risk-type', 'type');
  index(context, frtAllergyIntolerance, key, 0, resource.subjectElement, 'subject');
  index(context, frtAllergyIntolerance, key, 0, resource.subjectElement, 'patient');
  index(frtAllergyIntolerance, key, 0, resource.substanceElement, 'substance');

  for i := 0 to resource.eventList.Count - 1 do
  begin
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].substanceElement, 'substance');
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].onsetElement, 'onset');
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].exposureRouteElement, 'route');
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].durationElement, 'duration');
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].manifestationList, 'manifestation');
    index(frtAllergyIntolerance, key, 0, resource.eventList[i].severityElement, 'http://hl7.org/fhir/reaction-risk-severity', 'severity');
  end;
  patientCompartment(key, resource.subject);
end;
  {$ENDIF}



Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsSubstance : Array[TSearchParamsSubstance] of TSearchParamsSubstance = ( spSubstance__id, spSubstance__Language, spSubstance_Expiry, spSubstance_Identifier, spSubstance_Quantity, spSubstance_Substance, spSubstance_Type);
  {$ELSE}
  CHECK_TSearchParamsSubstance : Array[TSearchParamsSubstance] of TSearchParamsSubstance = ( spSubstance__id, spSubstance__language, spSubstance__lastUpdated, spSubstance__profile, spSubstance__security, spSubstance__tag,
     spSubstance_Expiry, spSubstance_Identifier, spSubstance_Quantity, spSubstance_Substance, spSubstance_Type);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesSubstance;
var
  a : TSearchParamsSubstance;
begin
  for a := low(TSearchParamsSubstance) to high(TSearchParamsSubstance) do
  begin
    assert(CHECK_TSearchParamsSubstance[a] = a);
    indexes.add(frtSubstance, CODES_TSearchParamsSubstance[a], DESC_TSearchParamsSubstance[a], TYPES_TSearchParamsSubstance[a], TARGETS_TSearchParamsSubstance[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSubstance(key: integer; id : String; context : TFhirResource; resource: TFhirSubstance);
var
  i : integer;
begin
  index(frtSubstance, key, 0, resource.type_, 'type');
  if resource.instance <> nil then
  begin
    index(frtSubstance, key, 0, resource.instance.identifier, 'identifier');
    index(frtSubstance, key, 0, resource.instance.expiryElement, 'expiry');
  end;
  for i := 0 to resource.ingredientList.count - 1 do
  begin
    index(frtSubstance, key, 0, resource.ingredientList[i].quantity, 'quantity');
    index(context, frtSubstance, key, 0, resource.ingredientList[i].substance, 'substance');
  end;
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirDate; name: String);
begin
  if (value <> nil) and (value.value <> nil) then
    index(aType, key, parent, asUTCMin(value), asUTCMax(value), name);
end;

procedure TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; value: TFhirBoolean; name: String);
var
  ndx : TFhirIndex;
begin
  if (value = nil) then
    exit;
  ndx := FIndexes.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown index '+name);
  if (ndx.TargetTypes <> []) then
    raise Exception.create('Attempt to index a simple type in an index that is a resource join');
  if not (ndx.SearchType in [SearchParamTypeString, SearchParamTypeNumber, SearchParamTypeToken]) then
    raise Exception.create('Unsuitable index '+name+' : '+CODES_TFhirSearchParamType[ndx.SearchType]+' indexing boolean');
  FEntries.add(key, parent, ndx, 0, BooleanToString(value.value), '', 0, ndx.SearchType);
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsOther : Array[TSearchParamsOther] of TSearchParamsOther = ( spOther__id, spOther__Language, spOther_Code, spOther_Created, spOther_Subject);
  {$ELSE}
  CHECK_TSearchParamsOther : Array[TSearchParamsOther] of TSearchParamsOther = ( spOther__id, spOther__language, spOther__lastUpdated, spOther__profile, spOther__security, spOther__tag,
     spOther_Code, spOther_Created, spOther_Patient, spOther_Subject);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesOther;
var
  a : TSearchParamsOther;
begin
  for a := low(TSearchParamsOther) to high(TSearchParamsOther) do
  begin
    assert(CHECK_TSearchParamsOther[a] = a);
    indexes.add(frtOther, CODES_TSearchParamsOther[a], DESC_TSearchParamsOther[a], TYPES_TSearchParamsOther[a], TARGETS_TSearchParamsOther[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOther(key: integer; id : String; context : TFhirResource; resource: TFhirOther);
begin
  index(frtOther, key, 0, resource.createdElement, 'created');
  index(frtOther, key, 0, resource.code, 'code');
  index(context, frtOther, key, 0, resource.subject, 'subject');
  index(context, frtOther, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

{$IFNDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsBasic : Array[TSearchParamsBasic] of TSearchParamsBasic = ( spBasic__id, spBasic__language, spBasic__lastUpdated, spBasic__profile, spBasic__security, spBasic__tag,
     spBasic_Code, spBasic_Created, spBasic_Patient, spBasic_Subject);

procedure TFhirIndexManager.buildIndexesBasic;
var
  a : TSearchParamsBasic;
begin
  for a := low(TSearchParamsBasic) to high(TSearchParamsBasic) do
  begin
    assert(CHECK_TSearchParamsBasic[a] = a);
    indexes.add(frtBasic, CODES_TSearchParamsBasic[a], DESC_TSearchParamsBasic[a], TYPES_TSearchParamsBasic[a], TARGETS_TSearchParamsBasic[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesBasic(key: integer; id : String; context : TFhirResource; resource: TFhirBasic);
begin
  index(frtBasic, key, 0, resource.createdElement, 'created');
  index(frtBasic, key, 0, resource.code, 'code');
  index(context, frtBasic, key, 0, resource.subject, 'subject');
  index(context, frtBasic, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;


Const
  CHECK_TSearchParamsCoverage : Array[TSearchParamsCoverage] of TSearchParamsCoverage = ( spCoverage__id, spCoverage__language, spCoverage__lastUpdated, spCoverage__profile, spCoverage__security, spCoverage__tag,
     spCoverage_Dependent, spCoverage_Group, spCoverage_Identifier, spCoverage_Issuer, spCoverage_Plan, spCoverage_Sequence, spCoverage_Subplan, spCoverage_Type);

procedure TFhirIndexManager.buildIndexesCoverage;
var
  a : TSearchParamsCoverage;
begin
  for a := low(TSearchParamsCoverage) to high(TSearchParamsCoverage) do
  begin
    assert(CHECK_TSearchParamsCoverage[a] = a);
    indexes.add(frtCoverage, CODES_TSearchParamsCoverage[a], DESC_TSearchParamsCoverage[a], TYPES_TSearchParamsCoverage[a], TARGETS_TSearchParamsCoverage[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCoverage(key: integer; id : String; context : TFhirResource; resource: TFhirCoverage);
begin
  index(frtCoverage, key, 0, resource.dependentElement, 'dependent');
  index(frtCoverage, key, 0, resource.groupElement, 'group');
  index(frtCoverage, key, 0, resource.identifierList, 'identifier');
  index(frtCoverage, key, 0, resource.planElement, 'plan');
  index(frtCoverage, key, 0, resource.sequenceElement, 'sequence');
  index(frtCoverage, key, 0, resource.subplanElement, 'subplan');
  index(frtCoverage, key, 0, resource.type_Element, 'type');
  index(context, frtCoverage, key, 0, resource.issuerElement, 'issuer');
end;



Const
  CHECK_TSearchParamsClaimResponse : Array[TSearchParamsClaimResponse] of TSearchParamsClaimResponse = ( spClaimResponse__id, spClaimResponse__language, spClaimResponse__lastUpdated, spClaimResponse__profile, spClaimResponse__security, spClaimResponse__tag,
     spClaimResponse_Identifier);

procedure TFhirIndexManager.buildIndexesClaimResponse;
var
  a : TSearchParamsClaimResponse;
begin
  for a := low(TSearchParamsClaimResponse) to high(TSearchParamsClaimResponse) do
  begin
    assert(CHECK_TSearchParamsClaimResponse[a] = a);
    indexes.add(frtClaimResponse, CODES_TSearchParamsClaimResponse[a], DESC_TSearchParamsClaimResponse[a], TYPES_TSearchParamsClaimResponse[a], TARGETS_TSearchParamsClaimResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesClaimResponse(key: integer; id : String; context : TFhirResource; resource: TFhirClaimResponse);
begin
  index(frtClaimResponse, key, 0, resource.identifierList, 'identifier');
end;


Const
  CHECK_TSearchParamsOralHealthClaim : Array[TSearchParamsOralHealthClaim] of TSearchParamsOralHealthClaim = ( spOralHealthClaim__id, spOralHealthClaim__language, spOralHealthClaim__lastUpdated, spOralHealthClaim__profile, spOralHealthClaim__security, spOralHealthClaim__tag,
     spOralHealthClaim_Identifier, spOralHealthClaim_Patient, spOralHealthClaim_Priority, spOralHealthClaim_Use);

procedure TFhirIndexManager.buildIndexesOralHealthClaim;
var
  a : TSearchParamsOralHealthClaim;
begin
  for a := low(TSearchParamsOralHealthClaim) to high(TSearchParamsOralHealthClaim) do
  begin
    assert(CHECK_TSearchParamsOralHealthClaim[a] = a);
    indexes.add(frtOralHealthClaim, CODES_TSearchParamsOralHealthClaim[a], DESC_TSearchParamsOralHealthClaim[a], TYPES_TSearchParamsOralHealthClaim[a], TARGETS_TSearchParamsOralHealthClaim[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOralHealthClaim(key: integer; id : String; context : TFhirResource; resource: TFhirOralHealthClaim);
begin
  index(frtOralHealthClaim, key, 0, resource.identifierList, 'identifier');
  index(frtOralHealthClaim, key, 0, resource.priorityElement, 'priority');
  index(frtOralHealthClaim, key, 0, resource.useElement, 'http://hl7.org/fhir/use-link', 'use');
  index(context, frtOralHealthClaim, key, 0, resource.patientElement, 'patient');
  patientCompartment(key, resource.patient);
end;


Const
  CHECK_TSearchParamsContract : Array[TSearchParamsContract] of TSearchParamsContract = ( spContract__id, spContract__language, spContract__lastUpdated, spContract__profile, spContract__security, spContract__tag,
     spContract_Patient, spContract_Subject);

procedure TFhirIndexManager.buildIndexesContract;
var
  a : TSearchParamsContract;
begin
  for a := low(TSearchParamsContract) to high(TSearchParamsContract) do
  begin
    assert(CHECK_TSearchParamsContract[a] = a);
    indexes.add(frtContract, CODES_TSearchParamsContract[a], DESC_TSearchParamsContract[a], TYPES_TSearchParamsContract[a], TARGETS_TSearchParamsContract[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesContract(key: integer; id : String; context : TFhirResource; resource: TFhirContract);
var
  i  : integer;
begin
  {$IFDEF FHIR-DSTU}
  index(context, frtContract, key, 0, resource.subject, 'subject');
  index(context, frtContract, key, 0, resource.subject, 'patient');
  {$ELSE}
  for i := 0 to resource.subjectList.Count - 1 do
  begin
    index(context, frtContract, key, 0, resource.subjectList[i], 'subject');
    index(context, frtContract, key, 0, resource.subjectList[i], 'patient');
  end;
  {$ENDIF}
end;


{$ENDIF}

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsSupply : Array[TSearchParamsSupply] of TSearchParamsSupply = ( spSupply__id, spSupply__Language, spSupply_Dispenseid, spSupply_Dispensestatus, spSupply_Identifier, spSupply_Kind, spSupply_Patient, spSupply_Status, spSupply_Supplier);
  {$ELSE}
  CHECK_TSearchParamsSupply : Array[TSearchParamsSupply] of TSearchParamsSupply = ( spSupply__id, spSupply__language, spSupply__lastUpdated, spSupply__profile, spSupply__security, spSupply__tag,
     spSupply_Dispenseid, spSupply_Dispensestatus, spSupply_Identifier, spSupply_Kind, spSupply_Patient, spSupply_Status, spSupply_Supplier);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesSupply;
var
  a : TSearchParamsSupply;
begin
  for a := low(TSearchParamsSupply) to high(TSearchParamsSupply) do
  begin
    assert(CHECK_TSearchParamsSupply[a] = a);
    indexes.add(frtSupply, CODES_TSearchParamsSupply[a], DESC_TSearchParamsSupply[a], TYPES_TSearchParamsSupply[a], TARGETS_TSearchParamsSupply[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSupply(key: integer; id : String; context : TFhirResource; resource: TFhirSupply);
var
  i : integer;
begin
  index(frtSupply, key, 0, resource.identifier, 'identifier');
  index(frtSupply, key, 0, resource.kind, 'kind');
  index(frtSupply, key, 0, resource.statusElement, 'http://hl7.org/fhir/valueset-supply-status', 'status');
  index(context, frtSupply, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.dispenseList.count - 1 do
  begin
    index(frtSupply, key, 0, resource.dispenseList[i].identifier, 'dispenseid');
    index(frtSupply, key, 0, resource.dispenseList[i].statusElement, 'http://hl7.org/fhir/valueset-supply-dispense-status', 'dispensestatus');
    index(context, frtSupply, key, 0, resource.dispenseList[i].supplier, 'supplier');
  end;
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsRelatedPerson : Array[TSearchParamsRelatedPerson] of TSearchParamsRelatedPerson = (spRelatedPerson__id, spRelatedPerson__Language, spRelatedPerson_Address, spRelatedPerson_Gender, spRelatedPerson_Identifier, spRelatedPerson_Name, spRelatedPerson_Patient, spRelatedPerson_Phonetic, spRelatedPerson_Telecom);
  {$ELSE}
  CHECK_TSearchParamsRelatedPerson : Array[TSearchParamsRelatedPerson] of TSearchParamsRelatedPerson = (spRelatedPerson__id, spRelatedPerson__language, spRelatedPerson__lastUpdated, spRelatedPerson__profile, spRelatedPerson__security, spRelatedPerson__tag,
     spRelatedPerson_Address, spRelatedPerson_Gender, spRelatedPerson_Identifier, spRelatedPerson_Name, spRelatedPerson_Patient, spRelatedPerson_Phonetic, spRelatedPerson_Telecom);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesRelatedPerson;
var
  a : TSearchParamsRelatedPerson;
begin
  for a := low(TSearchParamsRelatedPerson) to high(TSearchParamsRelatedPerson) do
  begin
    assert(CHECK_TSearchParamsRelatedPerson[a] = a);
    indexes.add(frtRelatedPerson, CODES_TSearchParamsRelatedPerson[a], DESC_TSearchParamsRelatedPerson[a], TYPES_TSearchParamsRelatedPerson[a], TARGETS_TSearchParamsRelatedPerson[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesRelatedPerson(key: integer; id : String; context : TFhirResource; resource: TFhirRelatedPerson);
var
  i : integer;
begin
  index(frtRelatedPerson, key, 0, resource.address, 'address');
  {$IFDEF FHIR-DSTU}
  index(frtRelatedPerson, key, 0, resource.gender, 'gender');
  {$ELSE}
  index(frtRelatedPerson, key, 0, resource.genderElement, 'http://hl7.org/fhir/administrative-gender', 'gender');
  {$ENDIF}
  for i := 0 to resource.identifierList.count - 1 do
    index(frtRelatedPerson, key, 0, resource.identifierList[i], 'identifier');
  index(frtRelatedPerson, key, 0, resource.name, 'name', 'phonetic');
  index(context, frtRelatedPerson, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.telecomList.count - 1 do
    index(frtRelatedPerson, key, 0, resource.telecomList[i], 'telecom');
end;

procedure TFhirIndexManager.patientCompartment(key : integer; reference: TFhirReference);
var
  sid : string;
begin
  if reference = nil then
    exit;
  if reference.reference = '' then
    exit;
  if StringStartsWith(reference.reference, '#') then
    exit; // what to do in this case?
  if not StringStartsWith(reference.reference, 'Patient/') then
    exit; // what to do in this case?
  sid := copy(reference.reference, 9, $FF);
  if (pos('/', sid) > 0) then
    sid := copy(sid, 1, pos('/', sid) - 1);
  patientCompartment(key, 'Patient', sid);
end;

procedure TFhirIndexManager.patientCompartment(key : integer; type_, id : String);
begin
  FSpaces.FDB.sql := 'Select ResourceKey from Ids as i, Types as t where i.ResourceTypeKey = t.ResourceTypeKey and ResourceName = :t and Id = :id';
  FSpaces.FDB.Prepare;
  FSpaces.FDB.BindString('t', type_);
  FSpaces.FDB.BindString('id', id);
  FSpaces.FDB.Execute;
  if FSpaces.FDB.FetchNext then
    FPatientCompartments.add(key, FSpaces.FDB.ColIntegerByName['ResourceKey'], id)
  else
    FPatientCompartments.add(key, 0, id);
  FSpaces.FDB.Terminate;
end;

procedure TFhirIndexManager.patientCompartmentNot(key : integer; type_, id : String);
begin
  FPatientCompartments.removeById(id);
end;

procedure TFhirIndexManager.processCompartmentTags(key: integer; id: String; tags: TFHIRAtomCategoryList);
var
  i : integer;
begin
  {$IFDEF FHIR-DSTU}
  for i := 0 to tags.Count - 1 do
    if StringStartsWith(tags[i].term, TAG_COMPARTMENT_IN) then
      patientCompartment(key, 'Patient', Copy(tags[i].term, length(TAG_COMPARTMENT_IN), $FF));
  {$ELSE}
  // raise Exception.Create('todo');
  {$ENDIF}
end;

procedure TFhirIndexManager.processUnCompartmentTags(key: integer; id: String; tags: TFHIRAtomCategoryList);
var
  i : integer;
begin
  {$IFDEF FHIR-DSTU}
  for i := 0 to tags.Count - 1 do
    if StringStartsWith(tags[i].term, TAG_COMPARTMENT_OUT) then
      patientCompartmentNot(key, 'Patient', Copy(tags[i].term, length(TAG_COMPARTMENT_OUT), $FF));
  {$ELSE}
  // raise Exception.Create('todo');
  {$ENDIF}
end;

function TFhirIndexManager.index(aType: TFhirResourceType; key, parent: integer; name: String): Integer;
var
  ndx : TFhirComposite;
begin
  ndx := FComposites.getByName(aType, name);
  if (ndx = nil) then
    raise Exception.create('Unknown composite index '+name+' on type '+CODES_TFhirResourceType[aType]);
  if (ndx.Key = 0) then
    raise Exception.create('unknown composite index '+ndx.Name);
  result := FEntries.add(key, parent, ndx);
end;

{ TFhirIndexSpaces }

constructor TFhirIndexSpaces.Create(db: TKDBConnection);
begin
  inherited create;
  FSpaces := TStringList.Create;
  FSpaces.Sorted := true;

  FDB := db;
  FDB.SQL := 'select * from Spaces';
  FDb.prepare;
  FDb.execute;
  while FDb.FetchNext do
    FSpaces.addObject(FDb.ColStringByName['Space'], TObject(FDb.ColIntegerByName['SpaceKey']));
  FDb.terminate;
end;


destructor TFhirIndexSpaces.destroy;
begin
  FSpaces.free;
  inherited;
end;

function TFhirIndexSpaces.ResolveSpace(space: String): integer;
var
  i : integer;
begin
  if FSpaces.Find(space, i) then
    result := integer(FSpaces.objects[i])
  else
  begin
    result := FDB.countSQL('select max(SpaceKey) from Spaces')+1;
    FDB.SQL := 'insert into Spaces (SpaceKey, Space) values ('+inttostr(result)+', :s)';
    FDb.prepare;
    FDB.BindString('s', space);
    FDb.execute;
    FDb.terminate;
    FSpaces.addObject(space, TObject(result));
  end;
end;


// --------- actual indexes -----------------------------------------------------------------------------------------------

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsConformance : Array[TSearchParamsConformance] of TSearchParamsConformance = ( spConformance__id, spConformance__Language, spConformance_Date, spConformance_Description, spConformance_Event, spConformance_Fhirversion, spConformance_Format, spConformance_Identifier, spConformance_Mode, spConformance_Name, spConformance_Profile, spConformance_Publisher, spConformance_Resource, spConformance_Security, spConformance_Software, spConformance_Status, spConformance_Supported_profile, spConformance_Version);
  {$ELSE}
  CHECK_TSearchParamsConformance : Array[TSearchParamsConformance] of TSearchParamsConformance = ( spConformance__id, spConformance__language, spConformance__lastUpdated, spConformance__profile, spConformance__security, spConformance__tag,
     spConformance_Date, spConformance_Description, spConformance_Event, spConformance_Fhirversion, spConformance_Format, spConformance_Identifier, spConformance_Mode, spConformance_Name, spConformance_Profile, spConformance_Publisher, spConformance_Resource, spConformance_Security, spConformance_Software, spConformance_Status, spConformance_Supported_profile, spConformance_Version);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesConformance();
var
  a : TSearchParamsConformance;
begin
  for a := low(TSearchParamsConformance) to high(TSearchParamsConformance) do
  begin
    assert(CHECK_TSearchParamsConformance[a] = a);
    indexes.add(frtConformance, CODES_TSearchParamsConformance[a], DESC_TSearchParamsConformance[a], TYPES_TSearchParamsConformance[a], TARGETS_TSearchParamsConformance[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesConformance(key : integer; id : String; context : TFhirResource; resource: TFhirConformance);
var
  i : integer;
  j : integer;
begin
  index(frtConformance, key, 0, resource.dateElement, 'date');
  index(frtConformance, key, 0, resource.nameElement, 'name');
  index(frtConformance, key, 0, resource.statusElement, 'http://hl7.org/fhir/conformance-statement-status', 'status');
  index(frtConformance, key, 0, resource.descriptionElement, 'description');
  index(frtConformance, key, 0, resource.publisherElement, 'publisher');
  if resource.software <> nil then
    index(frtConformance, key, 0, resource.software.nameElement, 'software');
  index(frtConformance, key, 0, resource.versionElement, 'version');
  index(frtConformance, key, 0, resource.fhirversionElement, 'fhirversion');
  index(frtConformance, key, 0, resource.identifierElement, 'identifier');

  for j := 0 to resource.formatList.Count - 1 do
    index(frtConformance, key, 0, resource.formatList[j], 'format');

  for j := 0 to resource.restList.Count - 1 do
  begin
    if resource.restList[j].security <> nil then
    begin
      for i := 0 to resource.restList[j].security.serviceList.count - 1 do
        index(frtConformance, key, 0, resource.restList[j].security.serviceList[i], 'security');
    end;
  end;


  for j := 0 to resource.restList.Count - 1 do
  begin
    for i := 0 to resource.restList[j].resourceList.count - 1 do
    begin
      index(context, frtConformance, key, 0, resource.restList[j].resourceList[i].profile, 'profile');
      index(frtConformance, key, 0, resource.restList[j].resourceList[i].type_Element, 'resource');
    end;
    index(frtConformance, key, 0, resource.restList[j].modeElement, 'http://hl7.org/fhir/restful-conformance-mode', 'mode');
  end;

  for j := 0 to resource.messagingList.Count - 1 Do
  begin
    for i := 0 to resource.messagingList[j].EventList.count - 1 do
    begin
      index(frtConformance, key, 0, resource.messagingList[j].EventList[i].focusElement, 'resource');
      index(context, frtConformance, key, 0, resource.messagingList[j].EventList[i].request, 'profile');
      index(context, frtConformance, key, 0, resource.messagingList[j].EventList[i].response, 'profile');
      index(frtConformance, key, 0, resource.messagingList[j].EventList[i].modeElement, 'http://hl7.org/fhir/message-conformance-event-mode', 'mode');
      index(frtConformance, key, 0, resource.messagingList[j].EventList[i].code, 'event');
    end;
  end;

  for i := 0 to resource.DocumentList.count - 1 do
    index(context, frtConformance, key, 0, resource.DocumentList[i].profile, 'profile');
  for i := 0 to resource.profileList.count - 1 do
    index(context, frtConformance, key, 0, resource.ProfileList[i], 'supported-profile');
end;

{ TFhirCompositionIndexManager }

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsComposition : Array[TSearchParamsComposition] of TSearchParamsComposition = ( spComposition__id, spComposition__Language, spComposition_Attester, spComposition_Author, spComposition_Class, spComposition_Context, spComposition_Date, spComposition_Identifier, spComposition_Section_content, spComposition_Section_type, spComposition_Subject, spComposition_Type);
  {$ELSE}
  CHECK_TSearchParamsComposition : Array[TSearchParamsComposition] of TSearchParamsComposition = ( spComposition__id, spComposition__language, spComposition__lastUpdated, spComposition__profile, spComposition__security, spComposition__tag,
     spComposition_Attester, spComposition_Author, spComposition_Class, spComposition_Confidentiality, spComposition_Context, spComposition_Date, spComposition_Identifier, spComposition_Patient, spComposition_Period, spComposition_Section, spComposition_Section_code, spComposition_Status, spComposition_Subject, spComposition_Title, spComposition_Type);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesComposition;
var
  a : TSearchParamsComposition;
begin
  for a := low(TSearchParamsComposition) to high(TSearchParamsComposition) do
  begin
    assert(CHECK_TSearchParamsComposition[a] = a);
    indexes.add(frtComposition, CODES_TSearchParamsComposition[a], DESC_TSearchParamsComposition[a], TYPES_TSearchParamsComposition[a], TARGETS_TSearchParamsComposition[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesComposition(key : integer; id : String; context : TFhirResource; resource: TFhirComposition);
  procedure indexSection(section : TFhirCompositionSection);
  var
    i : integer;
  begin
    {$IFNDEF FHIR-DSTU}
    index(frtComposition, key, 0, section.code, 'section-code');
    index(context, frtComposition, key, 0, section.content, 'section');
    {$ELSE}
    index(frtComposition, key, 0, section.code, 'section-type');
    index(context, frtComposition, key, 0, section.content, 'section-content');
    {$ENDIF}
    for i := 0 to section.SectionList.count - 1 do
      indexSection(section.SectionList[i]);
  end;
var
  i, j : integer;
begin
  index(frtComposition, key, 0, resource.dateElement, 'date');
  index(frtComposition, key, 0, resource.identifier, 'identifier');
  index(context, frtComposition, key, 0, resource.subject, 'subject');
  index(context, frtComposition, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(frtComposition, key, 0, resource.titleElement, 'title');
  index(frtComposition, key, 0, resource.type_Element, 'type');
  index(frtComposition, key, 0, resource.class_Element, 'class');
  index(frtComposition, key, 0, resource.statusElement, 'http://hl7.org/fhir/composition-status', 'status');
  index(frtComposition, key, 0, resource.confidentialityElement, 'confidentiality');
  {$IFDEF FHIR-DSTU}
  if resource.event <> nil then
    for i := 0 to resource.event.codeList.Count - 1 do
      index(frtComposition, key, 0, resource.event.codeList[i], 'context');
  {$ELSE}
  for j := 0 to resource.eventList.Count - 1 do
    for i := 0 to resource.eventList[j].codeList.Count - 1 do
    begin
      index(frtComposition, key, 0, resource.eventList[j].period, 'period');
      index(frtComposition, key, 0, resource.eventList[j].codeList[i], 'context');
    end;
  {$ENDIF}
  for i := 0 to resource.authorList.count - 1 do
    index(context, frtComposition, key, 0, resource.authorList[i], 'author');
  for i := 0 to resource.attesterList.count - 1 do
    index(context, frtComposition, key, 0, resource.attesterList[i].party, 'attester');
  for i := 0 to resource.SectionList.count - 1 do
    indexSection(resource.SectionList[i]);
end;


Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMessageHeader : Array[TSearchParamsMessageHeader] of TSearchParamsMessageHeader = ( spMessageHeader__id, spMessageHeader__Language);
  {$ELSE}
  CHECK_TSearchParamsMessageHeader : Array[TSearchParamsMessageHeader] of TSearchParamsMessageHeader = ( spMessageHeader__id, spMessageHeader__language, spMessageHeader__lastUpdated, spMessageHeader__profile, spMessageHeader__security, spMessageHeader__tag,
    spMessageHeader_Code, spMessageHeader_Data, spMessageHeader_Destination, spMessageHeader_Destination_uri, spMessageHeader_Event, spMessageHeader_Receiver, spMessageHeader_Response_id, spMessageHeader_Source, spMessageHeader_Source_uri, spMessageHeader_Src_id, spMessageHeader_Timestamp);

  {$ENDIF}

procedure TFhirIndexManager.buildIndexesMessageHeader;
var
  a : TSearchParamsMessageHeader;
begin
  for a := low(TSearchParamsMessageHeader) to high(TSearchParamsMessageHeader) do
  begin
    assert(CHECK_TSearchParamsMessageHeader[a] = a);
    indexes.add(frtMessageHeader, CODES_TSearchParamsMessageHeader[a], DESC_TSearchParamsMessageHeader[a], TYPES_TSearchParamsMessageHeader[a], TARGETS_TSearchParamsMessageHeader[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMessageHeader(key : integer; id : String; context : TFhirResource; resource: TFhirMessageHeader);
var
  i : integer;
begin
  {$IFNDEF FHIR-DSTU}
  if (resource.response <> nil) then
  begin
    index(frtMessageHeader, key, 0, resource.response.codeElement, 'http://hl7.org/fhir/response-code', 'code');
    index(frtMessageHeader, key, 0, resource.response.id, 'response-id');
  end;
  for i := 0 to resource.dataList.Count - 1 do
    index(context, frtMessageHeader, key, 0, resource.dataList[i], 'data');
  index(context, frtMessageHeader, key, 0, resource.receiver, 'receiver');
  index(frtMessageHeader, key, 0, resource.identifierElement, 'src-id');
  index(frtMessageHeader, key, 0, resource.timestampElement, 'timestamp');
  for i := 0 to resource.destinationList.Count - 1 do
  begin
    index(frtMessageHeader, key, 0, resource.destinationList[i].nameElement, 'destination');
    index(frtMessageHeader, key, 0, resource.destinationList[i].endpointElement, 'destination-uri');
  end;
  if resource.source <> nil then
  begin
    index(frtMessageHeader, key, 0, resource.source.nameElement, 'source');
    index(frtMessageHeader, key, 0, resource.source.endpointElement, 'source-uri');
  end;
  index(frtMessageHeader, key, 0, resource.event, 'event');
  {$ENDIF}
end;


Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsPractitioner : Array[TSearchParamsPractitioner] of TSearchParamsPractitioner = ( spPractitioner__id,  spPractitioner__Language,  spPractitioner_Address, {$IFNDEF FHIR-DSTU}spPractitioner_Communication, {$ENDIF}spPractitioner_Family, spPractitioner_Gender, spPractitioner_Given, spPractitioner_Identifier, spPractitioner_Name, spPractitioner_Organization, spPractitioner_Phonetic, spPractitioner_Telecom);
  {$ELSE}
  CHECK_TSearchParamsPractitioner : Array[TSearchParamsPractitioner] of TSearchParamsPractitioner = ( spPractitioner__id, spPractitioner__Language, spPractitioner__lastUpdated, spPractitioner__profile, spPractitioner__security, spPractitioner__tag,
    spPractitioner_Address, spPractitioner_Communication, spPractitioner_Family, spPractitioner_Gender, spPractitioner_Given, spPractitioner_Identifier, spPractitioner_Location, spPractitioner_Name, spPractitioner_Organization, spPractitioner_Phonetic, spPractitioner_Telecom);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesPractitioner;
var
  a : TSearchParamsPractitioner;
begin
  for a := low(TSearchParamsPractitioner) to high(TSearchParamsPractitioner) do
  begin
    assert(CHECK_TSearchParamsPractitioner[a] = a);
    indexes.add(frtPractitioner, CODES_TSearchParamsPractitioner[a], DESC_TSearchParamsPractitioner[a], TYPES_TSearchParamsPractitioner[a], TARGETS_TSearchParamsPractitioner[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPractitioner(key : integer; id : String; context : TFhirResource; resource: TFhirPractitioner);
var
  i, j : integer;
begin
  for i := 0 to resource.identifierList.count - 1 do
    index(frtPractitioner, key, 0, resource.identifierList[i], 'identifier');
  if resource.name <> nil then
  begin
    index(frtPractitioner, key, 0, resource.name, 'name', 'phonetic');
    for j := 0 to resource.name.givenList.count - 1 do
      index(frtPractitioner, key, 0, resource.name.givenList[j], 'given');
    for j := 0 to resource.name.familyList.count - 1 do
      index(frtPractitioner, key, 0, resource.name.familyList[j], 'family');
  end;
  for i := 0 to resource.telecomList.count - 1 do
    index(frtPractitioner, key, 0, resource.telecomList[i], 'telecom');
  for i := 0 to resource.locationList.count - 1 do
    index(context, frtPractitioner, key, 0, resource.locationList[i], 'location');
  {$IFDEF FHIR-DSTU}
  index(frtPractitioner, key, 0, resource.address, 'address');
  index(frtPractitioner, key, 0, resource.gender, 'gender');
  {$ELSE}
  index(frtPractitioner, key, 0, resource.genderElement, 'http://hl7.org/fhir/administrative-gender', 'gender');
  for i := 0 to resource.addressList.Count - 1 do
    index(frtPractitioner, key, 0, resource.addressList[i], 'address');
  for i := 0 to resource.communicationList.Count - 1 do
    index(frtPractitioner, key, 0, resource.communicationList, 'communication');
  {$ENDIF}
  index(context, frtPractitioner, key, 0, resource.organization, 'organization');
end;


Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsOrganization : Array[TSearchParamsOrganization] of TSearchParamsOrganization = ( spOrganization__id, spOrganization__Language, spOrganization_Active, spOrganization_Identifier, spOrganization_Name, spOrganization_Partof, spOrganization_Phonetic, spOrganization_Type);
  {$ELSE}
  CHECK_TSearchParamsOrganization : Array[TSearchParamsOrganization] of TSearchParamsOrganization = ( spOrganization__id, spOrganization__language, spOrganization__lastUpdated, spOrganization__profile, spOrganization__security, spOrganization__tag,
     spOrganization_Active, spOrganization_Identifier, spOrganization_Name, spOrganization_Partof, spOrganization_Phonetic, spOrganization_Type);
  {$ENDIF}



procedure TFhirIndexManager.buildIndexesOrganization;
var
  a : TSearchParamsOrganization;
begin
  for a := low(TSearchParamsOrganization) to high(TSearchParamsOrganization) do
  begin
    assert(CHECK_TSearchParamsOrganization[a] = a);
    indexes.add(frtOrganization, CODES_TSearchParamsOrganization[a], DESC_TSearchParamsOrganization[a], TYPES_TSearchParamsOrganization[a], TARGETS_TSearchParamsOrganization[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOrganization(key : integer;  id : String; context : TFhirResource; resource: TFhirOrganization);
var
  i : integer;
begin
  index(frtOrganization, key, 0, resource.active, 'active');
  index(frtOrganization, key, 0, resource.NameElement, 'name');
  index(frtOrganization, key, 0, EncodeNYSIISValue(resource.nameElement), 'phonetic');
  index(frtOrganization, key, 0, resource.type_, 'type');
  for i := 0 to resource.IdentifierList.Count - 1 Do
    if resource.IdentifierList[i] <> nil then
      index(frtOrganization, key, 0, resource.IdentifierList[i], 'identifier');
//  for i := 0 to resource.telecomList.Count - 1 Do
//    index(frtOrganization, key, 0, resource.telecomList[i].value, 'telecom');
//  for i := 0 to resource.addressList.Count - 1 Do
//    index(frtOrganization, key, 0, resource.addressList[i], 'address');

//  for j := 0 to resource.contactEntityList.Count - 1 Do
//  begin
//    contact := resource.contactEntityList[j];
//    index(frtOrganization, key, 0, contact.name, 'cname', '');
//   index(frtOrganization, key, 0, contact.address, 'caddress');
//    for i := 0 to contact.telecomList.Count - 1 Do
//      index(frtOrganization, key, 0, contact.telecomList[i].value, 'ctelecom');
//  end;
  index(context, frtOrganization, key, 0, resource.partOf, 'partOf');
end;


Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsGroup : Array[TSearchParamsGroup] of TSearchParamsGroup = ( spGroup__id, spGroup__Language, spGroup_Actual, spGroup_Characteristic, spGroup_Characteristic_value, spGroup_Code, spGroup_Exclude, spGroup_Identifier, spGroup_Member, spGroup_Type, spGroup_Value);
  {$ELSE}
  CHECK_TSearchParamsGroup : Array[TSearchParamsGroup] of TSearchParamsGroup = ( spGroup__id, spGroup__language, spGroup__lastUpdated, spGroup__profile, spGroup__security, spGroup__tag,
     spGroup_Actual, spGroup_Characteristic, spGroup_Characteristic_value, spGroup_Code, spGroup_Exclude, spGroup_Identifier, spGroup_Member, spGroup_Type, spGroup_Value);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesGroup;
var
  a : TSearchParamsGroup;
begin
  for a := low(TSearchParamsGroup) to high(TSearchParamsGroup) do
  begin
    assert(CHECK_TSearchParamsGroup[a] = a);
    indexes.add(frtGroup, CODES_TSearchParamsGroup[a], DESC_TSearchParamsGroup[a], TYPES_TSearchParamsGroup[a], TARGETS_TSearchParamsGroup[a]);
  end;
  composites.add(frtGroup, 'characteristic', ['value', 'value', 'code', 'characteristic']);
end;

procedure TFhirIndexManager.buildIndexValuesGroup(key : integer;  id : String; context : TFhirResource; resource: TFhirGroup);
var
  i, p : integer;
begin
  index(frtGroup, key, 0, resource.actual, 'actual');
  index(frtGroup, key, 0, resource.code, 'code');
  index(frtGroup, key, 0, resource.type_Element, 'http://hl7.org/fhir/group-type', 'type');
  index(frtGroup, key, 0, resource.identifier, 'identifier');

  for i := 0 to resource.memberList.Count - 1 Do
    index(context, frtGroup, key, 0, resource.memberList[i], 'member');

  for i := 0 to resource.characteristicList.Count - 1 Do
  begin
    p := index(frtGroup, key, 0, 'characteristic');
    index(frtGroup, key, p, resource.characteristicList[i].code, 'characteristic');
    index(frtGroup, key, 0, resource.characteristicList[i].exclude, 'exclude');
    if resource.characteristicList[i].value is TFhirBoolean then
      index(frtGroup, key, p, TFhirBoolean(resource.characteristicList[i].value).value, 'value')
    else if resource.characteristicList[i].value is TFhirString then
      index(frtGroup, key, p, TFhirString(resource.characteristicList[i].value), 'value')
    else if resource.characteristicList[i].value is TFhirCodeableConcept then
      index(frtGroup, key, p, TFhirCodeableConcept(resource.characteristicList[i].value), 'value')
  end;
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsObservation : Array[TSearchParamsObservation] of TSearchParamsObservation = ( spObservation__id, spObservation__Language, spObservation_Date, spObservation_Name,   spObservation_Name_value_x, spObservation_Performer, spObservation_Related, spObservation_Related_target, spObservation_Related_type, spObservation_Reliability, spObservation_Specimen, spObservation_Status, spObservation_Subject, spObservation_Value_concept, spObservation_Value_date, spObservation_Value_quantity, spObservation_Value_string);
  {$ELSE}
  CHECK_TSearchParamsObservation : Array[TSearchParamsObservation] of TSearchParamsObservation = ( spObservation__id, spObservation__language, spObservation__lastUpdated, spObservation__profile, spObservation__security, spObservation__tag,
     spObservation_Data_absent_reason, spObservation_Date, spObservation_Encounter, spObservation_Identifier, spObservation_Name, spObservation_Name_value_x, spObservation_Patient, spObservation_Performer, spObservation_Related, spObservation_Related_target, spObservation_Related_type, spObservation_Reliability, spObservation_Specimen, spObservation_Status, spObservation_Subject, spObservation_Value_concept, spObservation_Value_date, spObservation_Value_quantity, spObservation_Value_string);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesObservation;
var
  a : TSearchParamsObservation;
begin
  for a := low(TSearchParamsObservation) to high(TSearchParamsObservation) do
  begin
    assert(CHECK_TSearchParamsObservation[a] = a);
    indexes.add(frtObservation, CODES_TSearchParamsObservation[a], DESC_TSearchParamsObservation[a], TYPES_TSearchParamsObservation[a], TARGETS_TSearchParamsObservation[a]);
  end;
  composites.add(frtObservation, 'related', ['target', 'related-target', 'type', 'related-type']);
end;

procedure TFhirIndexManager.buildIndexValuesObservation(key : integer;  id : String; context : TFhirResource; resource: TFhirObservation);
var
  i, p : integer;
begin
  index(frtObservation, key, 0, resource.name, 'name');
  index(context, frtObservation, key, 0, resource.subject, 'subject');
//  index(context, frtObservation, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  if resource.applies is TFhirDateTime then
    index(frtObservation, key, 0, TFhirDateTime(resource.applies), 'date');
  index(frtObservation, key, 0, resource.statusElement, 'http://hl7.org/fhir/observation-status', 'status');
  index(frtObservation, key, 0, resource.reliabilityElement, 'http://hl7.org/fhir/observation-reliability', 'reliability');
  for i := 0 to resource.performerList.Count - 1 Do
    index(context, frtObservation, key, 0, resource.performerList[i], 'performer');
  index(context, frtObservation, key, 0, resource.specimen, 'specimen');

  if resource.value is TFhirQuantity then
    index(frtObservation, key, 0, TFhirQuantity(resource.value), 'value-quantity')
  else if resource.value is TFhirSampledData then
    index(frtObservation, key, 0, TFhirSampledData(resource.value), 'value-quantity')
  else if resource.value is TFhirRatio then
    index(frtObservation, key, 0, TFhirRatio(resource.value), 'value-quantity')
  else if resource.value is TFhirCodeableConcept then
    index(frtObservation, key, 0, TFhirCodeableConcept(resource.value), 'value-concept')
  else if resource.value is TFhirPeriod then
    index(frtObservation, key, 0, TFhirPeriod(resource.value), 'value-date')
  else if resource.value is TFhirString then
    index(frtObservation, key, 0, TFhirString(resource.value), 'value-string');

  {$IFNDEF FHIR-DSTU}
  index(context, frtObservation, key, 0, resource.encounter, 'encounter');
  index(frtObservation, key, 0, resource.identifier, 'identifier');
  index(frtObservation, key, 0, resource.dataAbsentReasonElement, 'http://hl7.org/fhir/data-absent-reason', 'data-absent-reason');
  {$ENDIF}

  for i := 0 to resource.relatedList.Count - 1 Do
  begin
    p := index(frtObservation, key, 0, 'related');
    index(frtObservation, key, p, resource.relatedList[i].type_Element, 'http://hl7.org/fhir/observation-relationshiptypes', 'related-type');
    index(context, frtObservation, key, p, resource.relatedList[i].target, 'related-target');
  end;
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsProfile : Array[TSearchParamsProfile] of TSearchParamsProfile = ( spProfile__id,  spProfile__Language, spProfile_Code, spProfile_Date, spProfile_Description, spProfile_Extension, spProfile_Identifier, spProfile_Name, spProfile_Publisher, spProfile_Status, spProfile_Type, {$IFNDEF FHIR-DSTU}spProfile_Url, {$ENDIF}spProfile_Valueset, spProfile_Version);
  {$ELSE}
  CHECK_TSearchParamsProfile : Array[TSearchParamsProfile] of TSearchParamsProfile = (spProfile__id, spProfile__language, spProfile__lastUpdated, spProfile__profile, spProfile__security, spProfile__tag,
    spProfile_Code, spProfile_Date, spProfile_Description, spProfile_Identifier, spProfile_Name, spProfile_Publisher, spProfile_Status, spProfile_Type, spProfile_Url, spProfile_Valueset, spProfile_Version);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesProfile;
var
  a : TSearchParamsProfile;
begin
  for a := low(TSearchParamsProfile) to high(TSearchParamsProfile) do
  begin
    assert(CHECK_TSearchParamsProfile[a] = a);
    indexes.add(frtProfile, CODES_TSearchParamsProfile[a], DESC_TSearchParamsProfile[a], TYPES_TSearchParamsProfile[a], TARGETS_TSearchParamsProfile[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesProfile(key : integer; id : String; context : TFhirResource; resource: TFhirProfile);
var
  i, j : integer;
  procedure indexElement(element : TFHIRProfileStructureElement);
  begin
    {$IFDEF FHIR-DSTU}
    if (element.definition <> nil) and
      (element.definition.binding <> nil) then
      if element.definition.binding.reference is TFhirUri then
        index(frtProfile, key, 0, TFhirUri(element.definition.binding.reference), 'valueset')
      else
        index(context, frtProfile, key, 0, TFhirReference(element.definition.binding.reference), 'valueset');
    {$ELSE}
    if (element.binding <> nil) then
      if element.binding.reference is TFhirUri then
        index(frtProfile, key, 0, TFhirUri(element.binding.reference), 'valueset')
      else
        index(context, frtProfile, key, 0, TFhirReference(element.binding.reference), 'valueset');
    {$ENDIF}
  end;
begin
  {$IFDEF FHIR-DSTU}
  index(frtProfile, key, 0, resource.identifier, 'identifier');
  for i := 0 to resource.ExtensionDefnList.count - 1 do
    index(frtProfile, key, 0, resource.ExtensionDefnList[i].codeElement, 'extension');
  {$ELSE}
  index(frtProfile, key, 0, resource.identifierList, 'identifier');
  index(frtProfile, key, 0, resource.urlElement, 'url');
  {$ENDIF}
  index(frtProfile, key, 0, resource.nameElement, 'name');
  index(frtProfile, key, 0, resource.dateElement, 'date');
  index(frtProfile, key, 0, resource.descriptionElement, 'description');
  index(frtProfile, key, 0, resource.statusElement, 'http://hl7.org/fhir/resource-profile-status', 'status');
  index(frtProfile, key, 0, resource.versionElement, 'version');
  index(frtProfile, key, 0, resource.publisherElement, 'publisher');
  for i := 0 to resource.CodeList.count - 1 Do
    index(frtProfile, key, 0, resource.CodeList[i], 'code');
  {$IFDEF FHIR-DSTU}
  for i := 0 to resource.StructureList.count - 1 do
  begin
    index(frtProfile, key, 0, resource.StructureList[i].type_ELement, 'type');
    for j := 0 to resource.structureList[i].elementList.Count - 1 do
      indexElement(resource.structureList[i].elementList[j]);
  end;
  {$ELSE}
  if resource.snapshot <> nil then
    for j := 0 to resource.snapshot.elementList.Count - 1 do
      indexElement(resource.snapshot.elementList[j]);
  if resource.differential <> nil then
    for j := 0 to resource.differential.elementList.Count - 1 do
      indexElement(resource.differential.elementList[j]);
  {$ENDIF}
end;


Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsPatient : Array[TSearchParamsPatient] of TSearchParamsPatient = ( spPatient__id,  spPatient__Language,  spPatient_Active, spPatient_Address, spPatient_Animal_breed, spPatient_Animal_species, spPatient_Birthdate, spPatient_Family, spPatient_Gender, spPatient_Given, spPatient_Identifier, spPatient_Language, spPatient_Link, spPatient_Name, spPatient_Phonetic, spPatient_Provider, spPatient_Telecom);
  {$ELSE}
  CHECK_TSearchParamsPatient : Array[TSearchParamsPatient] of TSearchParamsPatient = ( spPatient__id, spPatient__Language, spPatient__lastUPdated ,spPatient__profile, spPatient__security, spPatient__tag,
    spPatient_Active, spPatient_Address, spPatient_Animal_breed, spPatient_Animal_species, spPatient_Birthdate, spPatient_Careprovider, spPatient_Family, spPatient_Gender, spPatient_Given, spPatient_Identifier, spPatient_Language, spPatient_Link, spPatient_Name, spPatient_Organization, spPatient_Phonetic, spPatient_Telecom);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesPatient;
var
  a : TSearchParamsPatient;
begin
  for a := low(TSearchParamsPatient) to high(TSearchParamsPatient) do
  begin
    assert(CHECK_TSearchParamsPatient[a] = a);
    indexes.add(frtPatient, CODES_TSearchParamsPatient[a], DESC_TSearchParamsPatient[a], TYPES_TSearchParamsPatient[a], TARGETS_TSearchParamsPatient[a]);
  end;
  composites.add(frtPatient, 'name', ['given', 'given', 'family', 'family']);
end;

procedure TFhirIndexManager.buildIndexValuesPatient(key : integer; id : String; context : TFhirResource; resource: TFhirPatient);
var
  i, j : integer;
begin
  for i := 0 to resource.IdentifierList.Count - 1 Do
    if resource.IdentifierList[i] <> nil then
      index(frtPatient, key, 0, resource.IdentifierList[i], 'identifier');
  for i := 0 to resource.nameList.count - 1 do
  begin
    index(frtPatient, key, 0, resource.nameList[i], 'name', 'phonetic');
    for j := 0 to resource.nameList[i].givenList.count - 1 do
      index(frtPatient, key, 0, resource.nameList[i].givenList[j], 'given');
    for j := 0 to resource.nameList[i].familyList.count - 1 do
      index(frtPatient, key, 0, resource.nameList[i].familyList[j], 'family');
  end;

  for i := 0 to resource.telecomList.Count - 1 do
    index(frtPatient, key, 0, resource.telecomList[i].valueElement, 'telecom');
  for i := 0 to resource.AddressList.Count - 1 Do
    index(frtPatient, key, 0, resource.AddressList[i], 'address');
  {$IFDEF FHIR-DSTU}
  index(frtPatient, key, 0, resource.gender, 'gender');
  {$ELSE}
  index(frtPatient, key, 0, resource.genderElement, 'http://hl7.org/fhir/administrative-gender', 'gender');
  {$ENDIF}
  for i := 0 to resource.communicationList.Count - 1 Do
    index(frtPatient, key, 0, resource.communicationList[i], 'language');
  index(frtPatient, key, 0, resource.birthDateElement, 'birthdate');

  {$IFDEF FHIR-DSTU}
  index(context, frtPatient, key, 0, resource.managingOrganization, 'provider');
  {$ELSE}
  index(context, frtPatient, key, 0, resource.managingOrganization, 'organization');
  for i := 0 to resource.careProviderList.Count - 1 Do
    index(context, frtPatient, key, 0, resource.careProviderList[i], 'careprovider');
  {$ENDIF}

  for i := 0 to resource.link_List.count - 1 do
    index(context, frtPatient, key, 0, resource.link_List[i].other, 'link');

  index(frtPatient, key, 0, resource.active, 'active');

  if (resource.animal <> nil) then
  begin
    index(frtPatient, key, 0, resource.animal.species, 'animal-species');
    index(frtPatient, key, 0, resource.animal.breed, 'animal-breed');
  end;
  patientCompartment(key, 'patient', id);
end;

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsDiagnosticReport : Array[TSearchParamsDiagnosticReport] of TSearchParamsDiagnosticReport = ( spDiagnosticReport__id, spDiagnosticReport__Language, spDiagnosticReport_Date, spDiagnosticReport_Diagnosis, spDiagnosticReport_Identifier, spDiagnosticReport_Image, spDiagnosticReport_Issued, spDiagnosticReport_Name, spDiagnosticReport_Performer, spDiagnosticReport_Request, spDiagnosticReport_Result, spDiagnosticReport_Service, spDiagnosticReport_Specimen, spDiagnosticReport_Status, spDiagnosticReport_Subject);
  {$ELSE}
  CHECK_TSearchParamsDiagnosticReport : Array[TSearchParamsDiagnosticReport] of TSearchParamsDiagnosticReport = ( spDiagnosticReport__id, spDiagnosticReport__language, spDiagnosticReport__lastUpdated, spDiagnosticReport__profile, spDiagnosticReport__security, spDiagnosticReport__tag,
     spDiagnosticReport_Date, spDiagnosticReport_Diagnosis, spDiagnosticReport_Identifier, spDiagnosticReport_Image, spDiagnosticReport_Issued, spDiagnosticReport_Name, spDiagnosticReport_Patient, spDiagnosticReport_Performer, spDiagnosticReport_Request, spDiagnosticReport_Result, spDiagnosticReport_Service, spDiagnosticReport_Specimen, spDiagnosticReport_Status, spDiagnosticReport_Subject);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesDiagnosticReport;
var
  a : TSearchParamsDiagnosticReport;
begin
  for a := low(TSearchParamsDiagnosticReport) to high(TSearchParamsDiagnosticReport) do
  begin
    assert(CHECK_TSearchParamsDiagnosticReport[a] = a);
    indexes.add(frtDiagnosticReport, CODES_TSearchParamsDiagnosticReport[a], DESC_TSearchParamsDiagnosticReport[a], TYPES_TSearchParamsDiagnosticReport[a], TARGETS_TSearchParamsDiagnosticReport[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDiagnosticReport(key : integer; id : String; context : TFhirResource; resource: TFhirDiagnosticReport);
{  procedure IndexGroup(group : TFhirDiagnosticReportResults);
  var
    i : integer;
  begin
    index(frtDiagnosticReport, key, 0, group.name, 'group');
    index(frtDiagnosticReport, key, 0, resource, group.specimen, 'specimen');
    for i := 0 to group.resultList.count - 1 do
      index(frtDiagnosticReport, key, 0, resource, group.resultList[i], 'result');
    for i := 0 to group.groupList.count - 1 do
      IndexGroup(group.groupList[i]);
  end;}
var
  i, j, k : integer;
begin
  index(frtDiagnosticReport, key, 0, resource.statusElement, 'http://hl7.org/fhir/diagnostic-report-status', 'status');
  index(frtDiagnosticReport, key, 0, resource.identifier, 'identifier');
  for k := 0 to resource.RequestDetailList.count - 1 do
    index(context, frtDiagnosticReport, key, 0, resource.requestDetailList[k], 'request');

  index(frtDiagnosticReport, key, 0, resource.name, 'name');
  for j := 0 to resource.resultList.count - 1 do
    index(context, frtDiagnosticReport, key, 0, resource.resultList[j], 'result');

  index(context, frtDiagnosticReport, key, 0, resource.subject, 'subject');
  index(context, frtDiagnosticReport, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(context, frtDiagnosticReport, key, 0, resource.performer, 'performer');
  index(frtDiagnosticReport, key, 0, resource.issuedElement, 'issued');
  index(frtDiagnosticReport, key, 0, resource.identifier, 'identifier');
  index(frtDiagnosticReport, key, 0, resource.serviceCategory, 'service');
  if resource.diagnostic is TFhirPeriod then
    index(frtDiagnosticReport, key, 0, TFhirPeriod(resource.diagnostic), 'date')
  else
    index(frtDiagnosticReport, key, 0, TFhirDateTime(resource.diagnostic), 'date');

  for i := 0 to resource.specimenList.Count - 1 Do
    index(context, frtDiagnosticReport, key, 0, resource.specimenList[i], 'specimen');

  for i := 0 to resource.imageList.Count - 1 Do
    index(context, frtDiagnosticReport, key, 0, resource.imageList[i].link_, 'image');
  for i := 0 to resource.codedDiagnosisList.Count - 1 Do
    index(frtDiagnosticReport, key, 0, resource.codedDiagnosisList[i], 'diagnosis');
end;

{$IFDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsDeviceObservationReport : Array[TSearchParamsDeviceObservationReport] of TSearchParamsDeviceObservationReport = ( spDeviceObservationReport__id,  spDeviceObservationReport__Language,  spDeviceObservationReport_Channel, spDeviceObservationReport_Code, spDeviceObservationReport_Observation, spDeviceObservationReport_Source, spDeviceObservationReport_Subject);

procedure TFhirIndexManager.buildIndexesDeviceObservationReport;
var
  a : TSearchParamsDeviceObservationReport;
begin
  for a := low(TSearchParamsDeviceObservationReport) to high(TSearchParamsDeviceObservationReport) do
  begin
    assert(CHECK_TSearchParamsDeviceObservationReport[a] = a);
    indexes.add(frtDeviceObservationReport, CODES_TSearchParamsDeviceObservationReport[a], DESC_TSearchParamsDeviceObservationReport[a], TYPES_TSearchParamsDeviceObservationReport[a], TARGETS_TSearchParamsDeviceObservationReport[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDeviceObservationReport(key : integer; id : String; context : TFhirResource; resource: TFhirDeviceObservationReport);
var
  i, j, k : integer;
  vmd : TFhirDeviceObservationReportVirtualDevice;
  chan : TFhirDeviceObservationReportVirtualDeviceChannel;
begin
  index(context, frtDeviceObservationReport, key, 0, resource.source, 'source');
  index(context, frtDeviceObservationReport, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);

  for i := 0 to resource.virtualDeviceList.Count - 1 do
  begin
    vmd := resource.virtualDeviceList[i];
    index(frtDeviceObservationReport, key, 0, vmd.code, 'code');
    for j := 0 to vmd.channelList.Count - 1 do
    begin
      chan := vmd.channelList[j];
      index(frtDeviceObservationReport, key, 0, chan.code, 'channel');
      for k := 0 to chan.metricList.Count - 1 do
        index(context, frtDeviceObservationReport, key, 0, chan.metricList[k].observation, 'observation');
    end;
  end;
end;
{$ENDIF}

Const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsDiagnosticOrder : Array[TSearchParamsDiagnosticOrder] of TSearchParamsDiagnosticOrder = ( spDiagnosticOrder__id, spDiagnosticOrder__Language, spDiagnosticOrder_Actor, spDiagnosticOrder_Bodysite, spDiagnosticOrder_Code, spDiagnosticOrder_Encounter, spDiagnosticOrder_Event_date, spDiagnosticOrder_Event_status, spDiagnosticOrder_Event_status_date, spDiagnosticOrder_Identifier, spDiagnosticOrder_Item_date, spDiagnosticOrder_Item_past_status, spDiagnosticOrder_Item_status, spDiagnosticOrder_Item_status_date, spDiagnosticOrder_Orderer, spDiagnosticOrder_Specimen, spDiagnosticOrder_Status, spDiagnosticOrder_Subject);
  {$ELSE}
  CHECK_TSearchParamsDiagnosticOrder : Array[TSearchParamsDiagnosticOrder] of TSearchParamsDiagnosticOrder = ( spDiagnosticOrder__id, spDiagnosticOrder__language, spDiagnosticOrder__lastUpdated, spDiagnosticOrder__profile, spDiagnosticOrder__security, spDiagnosticOrder__tag,
    spDiagnosticOrder_Actor, spDiagnosticOrder_Bodysite, spDiagnosticOrder_Code, spDiagnosticOrder_Encounter, spDiagnosticOrder_Event_date, spDiagnosticOrder_Event_status, spDiagnosticOrder_Event_status_date, spDiagnosticOrder_Identifier, spDiagnosticOrder_Item_date, spDiagnosticOrder_Item_past_status, spDiagnosticOrder_Item_status, spDiagnosticOrder_Item_status_date, spDiagnosticOrder_Orderer, spDiagnosticOrder_Patient, spDiagnosticOrder_Specimen, spDiagnosticOrder_Status, spDiagnosticOrder_Subject);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesDiagnosticOrder;
var
  a : TSearchParamsDiagnosticOrder;
begin
  for a := low(TSearchParamsDiagnosticOrder) to high(TSearchParamsDiagnosticOrder) do
  begin
    assert(CHECK_TSearchParamsDiagnosticOrder[a] = a);
    indexes.add(frtDiagnosticOrder, CODES_TSearchParamsDiagnosticOrder[a], DESC_TSearchParamsDiagnosticOrder[a], TYPES_TSearchParamsDiagnosticOrder[a], TARGETS_TSearchParamsDiagnosticOrder[a]);
  end;
  composites.add(frtDiagnosticOrder, 'event', ['status', 'event-status', 'date', 'event-date']);
  composites.add(frtDiagnosticOrder, 'item', ['status', 'item-status', 'code', 'item-code', 'site', 'bodysite', 'event', 'item-event']);
  composites.add(frtDiagnosticOrder, 'item-event', ['status', 'item-past-status', 'date', 'item-date', 'actor', 'actor']);
end;

procedure TFhirIndexManager.buildIndexValuesDiagnosticOrder(key : integer; id : String; context : TFhirResource; resource: TFhirDiagnosticOrder);
var
  i, j, k, p, p1 : integer;
begin
  index(context, frtDiagnosticOrder, key, 0, resource.subject, 'subject');
  index(context, frtDiagnosticOrder, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(context, frtDiagnosticOrder, key, 0, resource.orderer, 'orderer');
  index(context, frtDiagnosticOrder, key, 0, resource.Encounter, 'encounter');
  for i := 0 to resource.specimenList.Count - 1 do
    index(context, frtDiagnosticOrder, key, 0, resource.specimenList[i], 'specimen');
  index(frtDiagnosticOrder, key, 0, resource.statusElement, 'http://hl7.org/fhir/diagnostic-order-status', 'status');
  for i := 0 to resource.identifierList.Count - 1 do
    index(frtDiagnosticOrder, key, 0, resource.identifierList[i], 'identifier');

  for j := 0 to resource.eventList.count - 1 do
  begin
    p := index(frtDiagnosticOrder, key, 0, 'event');
    index(context, frtDiagnosticOrder, key, p, resource.eventList[j].actor, 'actor');
    index(frtDiagnosticOrder, key, p, resource.eventList[j].statusElement, 'http://hl7.org/fhir/diagnostic-order-status', 'event-status');
    index(frtDiagnosticOrder, key, p, resource.eventList[j].dateTimeElement, 'event-date');
  end;

  for k := 0 to resource.itemList.count - 1 do
  begin
    p := index(frtDiagnosticOrder, key, 0, 'item');
    index(frtDiagnosticOrder, key, p, resource.itemList[k].code, 'code');
    for i := 0 to resource.itemList[k].specimenList.Count - 1 do
      index(context, frtDiagnosticOrder, key, 0, resource.itemList[k].specimenList[i], 'specimen');
    index(frtDiagnosticOrder, key, p, resource.itemList[k].bodySite, 'bodysite');
    index(frtDiagnosticOrder, key, p, resource.itemList[k].statusElement, 'http://hl7.org/fhir/diagnostic-order-status', 'item-status');
    for j := 0 to resource.itemList[k].eventList.count - 1 do
    begin
      p1 := index(frtDiagnosticOrder, key, p, 'item-event');
      index(context, frtDiagnosticOrder, key, p1, resource.itemList[k].eventList[j].actor, 'actor');
      index(frtDiagnosticOrder, key, p1, resource.itemList[k].eventList[j].statusElement, 'http://hl7.org/fhir/diagnostic-order-status', 'item-past-status');
      index(frtDiagnosticOrder, key, p1, resource.itemList[k].eventList[j].dateTimeElement, 'item-date');
    end;
  end;
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsValueSet : Array[TSearchParamsValueSet] of TSearchParamsValueSet = ( spValueSet__id, spValueSet__Language, spValueSet_Code, spValueSet_Date, spValueSet_Description, spValueSet_Identifier, spValueSet_Name, spValueSet_Publisher, spValueSet_Reference, spValueSet_Status, spValueSet_System, spValueSet_Version);
  {$ELSE}
  CHECK_TSearchParamsValueSet : Array[TSearchParamsValueSet] of TSearchParamsValueSet = ( spValueSet__id, spValueSet__language, spValueSet__lastUpdated, spValueSet__profile, spValueSet__security, spValueSet__tag,
     spValueSet_Code, spValueSet_Date, spValueSet_Description, spValueSet_Identifier, spValueSet_Name, spValueSet_Publisher, spValueSet_Reference, spValueSet_Status, spValueSet_System, spValueSet_Version);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesValueset;
var
  a : TSearchParamsValueset;
begin
  for a := low(TSearchParamsValueset) to high(TSearchParamsValueset) do
  begin
    assert(CHECK_TSearchParamsValueSet[a] = a);
    indexes.add(frtValueset, CODES_TSearchParamsValueset[a], DESC_TSearchParamsValueset[a], TYPES_TSearchParamsValueset[a], TARGETS_TSearchParamsValueset[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesValueset(key : integer; id : String; context : TFhirResource; resource: TFhirValueset);
  procedure indexConcepts(list : TFhirValueSetDefineConceptList);
  var
    i : integer;
  begin
    for i := 0 to list.Count - 1 do
    begin
      index(frtValueSet, key, 0, list[i].codeElement, 'code');
      indexConcepts(list[i].conceptList);
    end;
  end;
var
  i : integer;
begin
  index(frtValueSet, key, 0, resource.identifierElement, 'identifier');
  index(frtValueSet, key, 0, resource.versionElement, 'version');
  index(frtValueSet, key, 0, resource.nameElement, 'name');
  index(frtValueSet, key, 0, resource.statusElement, 'http://hl7.org/fhir/valueset-status', 'status');
  index(frtValueSet, key, 0, resource.dateElement, 'date');
  index(frtValueSet, key, 0, resource.publisherElement, 'publisher');
  index(frtValueSet, key, 0, resource.descriptionElement, 'description');
  if (resource.define <> nil) then
  begin
    index(frtValueSet, key, 0, resource.define.systemElement, 'system');
    indexConcepts(resource.define.conceptList);
  end;
  if resource.compose <> nil then
  begin
    for i := 0 to resource.compose.importList.Count - 1 do
      index(frtValueSet, key, 0, resource.compose.importList[i], 'reference');
    for i := 0 to resource.compose.includeList.Count - 1 do
      index(frtValueSet, key, 0, resource.compose.includeList[i].systemElement, 'reference');
    for i := 0 to resource.compose.excludeList.Count - 1 do
      index(frtValueSet, key, 0, resource.compose.excludeList[i].systemElement, 'reference');
  end;
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsConceptMap : Array[TSearchParamsConceptMap] of TSearchParamsConceptMap = ( spConceptMap__id, spConceptMap__Language, spConceptMap_Date, spConceptMap_Dependson, spConceptMap_Description, spConceptMap_Identifier, spConceptMap_Name, spConceptMap_Product, spConceptMap_Publisher, spConceptMap_Source, spConceptMap_Status, spConceptMap_System, spConceptMap_Target, spConceptMap_Version);
  {$ELSE}
  CHECK_TSearchParamsConceptMap : Array[TSearchParamsConceptMap] of TSearchParamsConceptMap = ( spConceptMap__id, spConceptMap__language, spConceptMap__lastUpdated, spConceptMap__profile, spConceptMap__security, spConceptMap__tag,
     spConceptMap_Date, spConceptMap_Dependson, spConceptMap_Description, spConceptMap_Identifier, spConceptMap_Name, spConceptMap_Product, spConceptMap_Publisher, spConceptMap_Source, spConceptMap_Status, spConceptMap_System, spConceptMap_Target, spConceptMap_Version);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesConceptMap;
var
  a : TSearchParamsConceptMap;
begin
  for a := low(TSearchParamsConceptMap) to high(TSearchParamsConceptMap) do
  begin
    assert(CHECK_TSearchParamsConceptMap[a] = a);
    indexes.add(frtConceptMap, CODES_TSearchParamsConceptMap[a], DESC_TSearchParamsConceptMap[a], TYPES_TSearchParamsConceptMap[a], TARGETS_TSearchParamsConceptMap[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesConceptMap(key : integer; id : String; context : TFhirResource; resource: TFhirConceptMap);
var
  i, j, k : integer;
  list : TFhirConceptMapConceptList;
begin
  index(frtConceptMap, key, 0, resource.identifierElement, 'identifier');
  index(frtConceptMap, key, 0, resource.versionElement, 'version');
  index(frtConceptMap, key, 0, resource.nameElement, 'name');
  index(frtConceptMap, key, 0, resource.statusElement, 'http://hl7.org/fhir/valueset-status', 'status');
  index(frtConceptMap, key, 0, resource.dateElement, 'date');
  index(frtConceptMap, key, 0, resource.publisherElement, 'publisher');
  index(frtConceptMap, key, 0, resource.descriptionElement, 'description');

  {$IFDEF FHIR-DSTU}
  index(context, frtConceptMap, key, 0, resource.source, 'source');
  index(context, frtConceptMap, key, 0, resource.target, 'target');
  list := resource.conceptList;
  {$ELSE}
  if resource.source is TFhirReference then
    index(context, frtConceptMap, key, 0, TFhirReference(resource.source), 'source')
  else
    index(frtConceptMap, key, 0, TFhirURI(resource.source), 'source');
  if resource.target is TFhirReference then
    index(context, frtConceptMap, key, 0, TFhirReference(resource.target), 'target')
  else
    index(frtConceptMap, key, 0, TFhirURI(resource.target), 'target');
  list := resource.elementList;
  {$ENDIF}

  for i := 0 to list.count - 1 do
  begin
    index(frtConceptMap, key, 0, list[i].codeSystemElement, 'system');
    for j := 0 to list[i].dependsOnList.Count - 1 do
      index(frtConceptMap, key, 0, list[i].dependsOnList[j].elementElement, 'dependson');
    for j := 0 to list[i].mapList.Count - 1 do
    begin
      index(frtConceptMap, key, 0, list[i].mapList[j].codeSystemElement, 'system');
      for k := 0 to list[i].mapList[j].productList.Count - 1 do
        index(frtConceptMap, key, 0, list[i].mapList[j].productList[k].elementElement, 'dependson');
    end;
  end;
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsDevice : Array[TSearchParamsDevice] of TSearchParamsDevice = ( spDevice__id, spDevice__Language, spDevice_Identifier, spDevice_Location, spDevice_Manufacturer, spDevice_Model, spDevice_Organization, spDevice_Patient, spDevice_Type, spDevice_Udi);
  {$ELSE}
  CHECK_TSearchParamsDevice : Array[TSearchParamsDevice] of TSearchParamsDevice = ( spDevice__id, spDevice__language, spDevice__lastUpdated, spDevice__profile, spDevice__security, spDevice__tag,
     spDevice_Identifier, spDevice_Location, spDevice_Manufacturer, spDevice_Model, spDevice_Organization, spDevice_Patient, spDevice_Type, spDevice_Udi);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesDevice;
var
  a : TSearchParamsDevice;
begin
  for a := low(TSearchParamsDevice) to high(TSearchParamsDevice) do
  begin
    assert(CHECK_TSearchParamsDevice[a] = a);
    indexes.add(frtDevice, CODES_TSearchParamsDevice[a], DESC_TSearchParamsDevice[a], TYPES_TSearchParamsDevice[a], TARGETS_TSearchParamsDevice[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDevice(key : integer; id : String; context : TFhirResource; resource: TFhirDevice);
var
  i : integer;
begin
  for i  := 0 to resource.identifierList.count - 1 do
    index(frtDevice, key, 0, resource.identifierList[i], 'identifier');
  index(frtDevice, key, 0, resource.udiElement, 'udi');
  index(context, frtDevice, key, 0, resource.location, 'location');
  index(frtDevice, key, 0, resource.manufacturerElement, 'manufacturer');
  index(frtDevice, key, 0, resource.modelElement, 'model');
  index(context, frtDevice, key, 0, resource.owner, 'organization');
  index(context, frtDevice, key, 0, resource.patient, 'patient');
  index(frtDevice, key, 0, resource.type_, 'type');
  patientCompartment(key, resource.patient);
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsSecurityEvent : Array[TSearchParamsSecurityEvent] of TSearchParamsSecurityEvent = ( spSecurityEvent__id, spSecurityEvent__Language, spSecurityEvent_Action, spSecurityEvent_Address, spSecurityEvent_Altid, spSecurityEvent_Date, spSecurityEvent_Desc, spSecurityEvent_Identity, spSecurityEvent_Name, spSecurityEvent_Object_type, spSecurityEvent_Patientid, spSecurityEvent_Reference, spSecurityEvent_Site, spSecurityEvent_Source, spSecurityEvent_Subtype, spSecurityEvent_Type, spSecurityEvent_User);
  {$ELSE}
  CHECK_TSearchParamsSecurityEvent : Array[TSearchParamsSecurityEvent] of TSearchParamsSecurityEvent = ( spSecurityEvent__id, spSecurityEvent__language, spSecurityEvent__lastUpdated, spSecurityEvent__profile, spSecurityEvent__security, spSecurityEvent__tag,
     spSecurityEvent_Action, spSecurityEvent_Address, spSecurityEvent_Altid, spSecurityEvent_Date, spSecurityEvent_Desc, spSecurityEvent_Identity, spSecurityEvent_Name, spSecurityEvent_Object_type, spSecurityEvent_Patient, spSecurityEvent_Patientid, spSecurityEvent_Reference, spSecurityEvent_Site, spSecurityEvent_Source, spSecurityEvent_Subtype, spSecurityEvent_Type, spSecurityEvent_User);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesSecurityEvent;
var
  a : TSearchParamsSecurityEvent;
begin
  for a := low(TSearchParamsSecurityEvent) to high(TSearchParamsSecurityEvent) do
  begin
    assert(CHECK_TSearchParamsSecurityEvent[a] = a);
    indexes.add(frtSecurityEvent, CODES_TSearchParamsSecurityEvent[a], DESC_TSearchParamsSecurityEvent[a], TYPES_TSearchParamsSecurityEvent[a], TARGETS_TSearchParamsSecurityEvent[a]);
  end;
end;


procedure TFhirIndexManager.buildIndexValuesSecurityEvent(key : integer; id : String; context : TFhirResource; resource: TFhirSecurityEvent);
var
  i : integer;
begin
  index(frtSecurityEvent, key, 0, resource.event.type_, 'type');
  index(frtSecurityEvent, key, 0, resource.event.actionElement, 'http://hl7.org/fhir/security-event-action', 'action');
  index(frtSecurityEvent, key, 0, resource.event.dateTimeElement, 'date');
  for i := 0 to resource.event.subTypeList.count - 1 do
    index(frtSecurityEvent, key, 0, resource.event.subtypeList[i], 'subtype');

  for i := 0 to resource.participantList.count - 1 do
  begin
    index(frtSecurityEvent, key, 0, resource.participantList[i].userIdElement, 'user');
    index(frtSecurityEvent, key, 0, resource.participantList[i].altIdElement, 'altid');
    index(frtSecurityEvent, key, 0, resource.participantList[i].nameElement, 'name');
    if resource.participantList[i].network <> nil then
      index(frtSecurityEvent, key, 0, resource.participantList[i].network.identifierElement, 'address');
  end;

  if resource.source <> nil Then
  begin
    index(frtSecurityEvent, key, 0, resource.source.identifierElement, 'source');
    index(frtSecurityEvent, key, 0, resource.source.siteElement, 'site');
  end;

  for i := 0 to resource.object_List.count - 1 do
  begin
    index(frtSecurityEvent, key, 0, resource.object_List[i].type_Element, 'http://hl7.org/fhir/object-type', 'object-type');
    index(frtSecurityEvent, key, 0, resource.object_List[i].identifier, 'identity');
    index(context, frtSecurityEvent, key, 0, resource.object_List[i].reference, 'reference');
    patientCompartment(key, resource.object_List[i].reference);
    index(frtSecurityEvent, key, 0, resource.object_List[i].nameElement, 'desc');
  end;
  // todo: spAudit_Patientid, patient
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsCondition : Array[TSearchParamsCondition] of TSearchParamsCondition = ( spCondition__id, spCondition__Language, spCondition_Asserter, spCondition_Category, spCondition_Code, spCondition_Date_asserted, spCondition_Encounter, spCondition_Evidence, spCondition_Location, spCondition_Onset, spCondition_Related_code, spCondition_Related_item, spCondition_Severity, spCondition_Stage, spCondition_Status, spCondition_Subject);
  {$ELSE}
  CHECK_TSearchParamsCondition : Array[TSearchParamsCondition] of TSearchParamsCondition = ( spCondition__id, spCondition__language, spCondition__lastUpdated, spCondition__profile, spCondition__security, spCondition__tag,
     spCondition_Asserter, spCondition_Category, spCondition_Code, spCondition_Date_asserted, spCondition_Dueto_code, spCondition_Dueto_item, spCondition_Encounter, spCondition_Evidence, spCondition_Following_code, spCondition_Following_item, spCondition_Location, spCondition_Onset, spCondition_Patient, spCondition_Severity, spCondition_Stage, spCondition_Status, spCondition_Subject);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesCondition;
var
  a : TSearchParamsCondition;
begin
  for a := low(TSearchParamsCondition) to high(TSearchParamsCondition) do
  begin
    assert(CHECK_TSearchParamsCondition[a] = a);
    indexes.add(frtCondition, CODES_TSearchParamsCondition[a], DESC_TSearchParamsCondition[a], TYPES_TSearchParamsCondition[a], TARGETS_TSearchParamsCondition[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCondition(key : integer; id : String; context : TFhirResource; resource: TFhirCondition);
var
  i : integer;
begin
  index(frtCondition, key, 0, resource.code, 'code');
  index(frtCondition, key, 0, resource.statusElement, 'http://hl7.org/fhir/condition-status', 'status');
  index(frtCondition, key, 0, resource.severity, 'severity');
  index(frtCondition, key, 0, resource.category, 'category');
  index(context, frtCondition, key, 0, resource.subject, 'subject');
  index(context, frtCondition, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(context, frtCondition, key, 0, resource.Encounter, 'encounter');
  index(context, frtCondition, key, 0, resource.asserter, 'asserter');
  {$IFDEF FHIR-DSTU}
  for i := 0 to resource.relatedItemList.count - 1 do
  begin
    index(frtCondition, key, 0, resource.relatedItemList[i].code, 'related-code');
    index(context, frtCondition, key, 0, resource.relatedItemList[i].target, 'related-item');
  end;
  {$ELSE}
  for i := 0 to resource.dueToList.count - 1 do
  begin
    index(frtCondition, key, 0, resource.dueToList[i].codeableConcept, 'dueto-code');
    index(context, frtCondition, key, 0, resource.dueToList[i].target, 'dueto-item');
  end;

  for i := 0 to resource.occurredFollowingList.count - 1 do
  begin
    index(frtCondition, key, 0, resource.occurredFollowingList[i].codeableConcept, 'following-code');
    index(context, frtCondition, key, 0, resource.occurredFollowingList[i].target, 'following-item');
  end;

  {$ENDIF}
  index(frtCondition, key, 0, resource.dateAssertedElement, 'date-asserted');
// todo  index(frtCondition, key, 0, resource.onset, 'onset');
  for i := 0 to resource.evidenceList.count - 1 do
    index(frtCondition, key, 0, resource.evidenceList[i].code, 'evidence');
  for i := 0 to resource.locationList.count - 1 do
    index(frtCondition, key, 0, resource.locationList[i].code, 'location');
  if resource.stage <> nil then
    index(frtCondition, key, 0, resource.stage.summary, 'stage');
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsOperationOutcome : Array[TSearchParamsOperationOutcome] of TSearchParamsOperationOutcome = ( spOperationOutcome__id, spOperationOutcome__Language);
  {$ELSE}
  CHECK_TSearchParamsOperationOutcome : Array[TSearchParamsOperationOutcome] of TSearchParamsOperationOutcome = ( spOperationOutcome__id, spOperationOutcome__language, spOperationOutcome__lastUpdated, spOperationOutcome__profile, spOperationOutcome__security, spOperationOutcome__tag);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesOperationOutcome;
var
  a : TSearchParamsOperationOutcome;
begin
  for a := low(TSearchParamsOperationOutcome) to high(TSearchParamsOperationOutcome) do
  begin
    assert(CHECK_TSearchParamsOperationOutcome[a] = a);
    indexes.add(frtOperationOutcome, CODES_TSearchParamsOperationOutcome[a], DESC_TSearchParamsOperationOutcome[a], TYPES_TSearchParamsOperationOutcome[a], TARGETS_TSearchParamsOperationOutcome[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOperationOutcome(key : integer; id : String; context : TFhirResource; resource: TFhirOperationOutcome);
begin
end;


procedure TFhirIndexManager.buildIndexesBinary;
begin
  indexes.add(frtBinary, '_id', '_id', SearchParamTypeToken, []);
end;

procedure TFhirIndexManager.buildIndexValuesBinary(key : integer; id : String; context : TFhirResource; resource: TFhirBinary);
begin
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsProvenance : Array[TSearchParamsProvenance] of TSearchParamsProvenance = ( spProvenance__id,  spProvenance__Language,  spProvenance_End, spProvenance_Location, spProvenance_Party, spProvenance_Partytype, spProvenance_Start, spProvenance_Target);
  {$ELSE}
  CHECK_TSearchParamsProvenance : Array[TSearchParamsProvenance] of TSearchParamsProvenance = (spProvenance__id, spProvenance__language, spProvenance__lastUpdated, spProvenance__profile, spProvenance__security, spProvenance__tag,
    spProvenance_End, spProvenance_Location, spProvenance_Party, spProvenance_Partytype, spProvenance_Patient, spProvenance_Start, spProvenance_Target);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesProvenance;
var
  a : TSearchParamsProvenance;
begin
  for a := low(TSearchParamsProvenance) to high(TSearchParamsProvenance) do
  begin
    assert(CHECK_TSearchParamsProvenance[a] = a);
    indexes.add(frtProvenance, CODES_TSearchParamsProvenance[a], DESC_TSearchParamsProvenance[a], TYPES_TSearchParamsProvenance[a], TARGETS_TSearchParamsProvenance[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesProvenance(key : integer; id : String; context : TFhirResource; resource: TFhirProvenance);
var
  i : integer;
begin
  for i := 0 to resource.targetList.Count - 1 do
  index(context, frtProvenance, key, 0, resource.targetList[i], 'target');
  if (resource.period <> nil) then
  begin
    index(frtProvenance, key, 0, resource.period.startElement, 'start');
    index(frtProvenance, key, 0, resource.period.end_Element, 'end');
  end;
  index(context, frtProvenance, key, 0, resource.location, 'location');

  for i := 0 to resource.entityList.Count - 1 do
  begin
    index(frtProvenance, key, 0, resource.entityList[i].referenceElement, 'party');
    index(frtProvenance, key, 0, resource.entityList[i].type_Element, 'partytype');
  end;
  // todo: spProvenance_Patient, {@enum.value spProvenance_Patient A patient that the target resource(s) refer to }
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedication : Array[TSearchParamsMedication] of TSearchParamsMedication = ( spMedication__id, spMedication__Language, spMedication_Code, spMedication_Container, spMedication_Content, spMedication_Form, spMedication_Ingredient, spMedication_Manufacturer, spMedication_Name);
  {$ELSE}
  CHECK_TSearchParamsMedication : Array[TSearchParamsMedication] of TSearchParamsMedication = ( spMedication__id, spMedication__language, spMedication__lastUpdated, spMedication__profile, spMedication__security, spMedication__tag,
     spMedication_Code, spMedication_Container, spMedication_Content, spMedication_Form, spMedication_Ingredient, spMedication_Manufacturer, spMedication_Name);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesMedication;
var
  a : TSearchParamsMedication;
begin
  for a := low(TSearchParamsMedication) to high(TSearchParamsMedication) do
  begin
    assert(CHECK_TSearchParamsMedication[a] = a);
    indexes.add(frtMedication, CODES_TSearchParamsMedication[a], DESC_TSearchParamsMedication[a], TYPES_TSearchParamsMedication[a], TARGETS_TSearchParamsMedication[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedication(key : integer; id : String; context : TFhirResource; resource: TFhirMedication);
var
  i : integer;
begin
  index(frtMedication, key, 0, resource.code, 'code');
  index(frtMedication, key, 0, resource.nameElement, 'name');
  index(context, frtMedication, key, 0, resource.manufacturer, 'manufacturer');
  if (resource.package <> nil) then
  begin
    index(frtMedication, key, 0, resource.package.container, 'container');
    for i := 0 to resource.package.contentList.count - 1 do
      index(context, frtMedication, key, 0, resource.package.contentList[i].item, 'content');
  end;
  if (resource.product <> nil) then
  begin
    index(frtMedication, key, 0, resource.product.form, 'form');
    for i := 0 to resource.product.ingredientList.count - 1 do
      index(context, frtMedication, key, 0, resource.product.ingredientList[i].item, 'ingredient');
  end;
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedicationAdministration : Array[TSearchParamsMedicationAdministration] of TSearchParamsMedicationAdministration = ( spMedicationAdministration__id, spMedicationAdministration__Language, spMedicationAdministration_Device, spMedicationAdministration_Encounter, spMedicationAdministration_Identifier, spMedicationAdministration_Medication, spMedicationAdministration_Notgiven, spMedicationAdministration_Patient, spMedicationAdministration_Prescription, spMedicationAdministration_Status, spMedicationAdministration_Whengiven);
  {$ELSE}
  CHECK_TSearchParamsMedicationAdministration : Array[TSearchParamsMedicationAdministration] of TSearchParamsMedicationAdministration = ( spMedicationAdministration__id, spMedicationAdministration__language, spMedicationAdministration__lastUpdated, spMedicationAdministration__profile, spMedicationAdministration__security, spMedicationAdministration__tag,
     spMedicationAdministration_Device, spMedicationAdministration_Effectivetime, spMedicationAdministration_Encounter, spMedicationAdministration_Identifier, spMedicationAdministration_Medication, spMedicationAdministration_Notgiven, spMedicationAdministration_Patient, spMedicationAdministration_Prescription, spMedicationAdministration_Status);
  {$ENDIF}




procedure TFhirIndexManager.buildIndexesMedicationAdministration;
var
  a : TSearchParamsMedicationAdministration;
begin
  for a := low(TSearchParamsMedicationAdministration) to high(TSearchParamsMedicationAdministration) do
  begin
    assert(CHECK_TSearchParamsMedicationAdministration[a] = a);
    indexes.add(frtMedicationAdministration, CODES_TSearchParamsMedicationAdministration[a], DESC_TSearchParamsMedicationAdministration[a], TYPES_TSearchParamsMedicationAdministration[a], TARGETS_TSearchParamsMedicationAdministration[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedicationAdministration(key : integer; id : String; context : TFhirResource; resource: TFhirMedicationAdministration);
var
  i : integer;
begin
  index(context, frtMedicationAdministration, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(context, frtMedicationAdministration, key, 0, resource.Encounter, 'encounter');
  index(context, frtMedicationAdministration, key, 0, resource.prescription, 'prescription');
  index(frtMedicationAdministration, key, 0, resource.wasNotGiven, 'notgiven');
  {$IFDEF FHIR-DSTU}
  index(frtMedicationAdministration, key, 0, resource.whengiven, 'whengiven');
  {$ELSE}
  if resource.effectiveTime is TFhirPeriod then
    index(frtMedicationAdministration, key, 0, TFhirPeriod(resource.effectiveTime), 'effectivetime')
  else
    index(frtMedicationAdministration, key, 0, TFhirDateTime(resource.effectiveTime), 'effectivetime');
  {$ENDIF}

  index(frtMedicationAdministration, key, 0, resource.statusElement, 'http://hl7.org/fhir/medication-admin-status', 'status');
  index(context, frtMedicationAdministration, key, 0, resource.medication, 'medication');
  for i := 0 to resource.identifierList.Count - 1 do
    index(frtMedicationAdministration, key, 0, resource.identifierList[i], 'identifier');
  if resource.Encounter <> nil then
    index(context, frtMedicationAdministration, key, 0, resource.Encounter, 'Encounter');
  for i := 0 to resource.deviceList.Count - 1 do
    index(context, frtMedicationAdministration, key, 0, resource.deviceList[i], 'device');
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedicationPrescription : Array[TSearchParamsMedicationPrescription] of TSearchParamsMedicationPrescription = ( spMedicationPrescription__id, spMedicationPrescription__Language, spMedicationPrescription_Datewritten, spMedicationPrescription_Encounter, spMedicationPrescription_Identifier, spMedicationPrescription_Medication, spMedicationPrescription_Patient, spMedicationPrescription_Status);
  {$ELSE}
  CHECK_TSearchParamsMedicationPrescription : Array[TSearchParamsMedicationPrescription] of TSearchParamsMedicationPrescription = ( spMedicationPrescription__id, spMedicationPrescription__language, spMedicationPrescription__lastUpdated, spMedicationPrescription__profile, spMedicationPrescription__security, spMedicationPrescription__tag,
     spMedicationPrescription_Datewritten, spMedicationPrescription_Encounter, spMedicationPrescription_Identifier, spMedicationPrescription_Medication, spMedicationPrescription_Patient, spMedicationPrescription_Status);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesMedicationPrescription;
var
  a : TSearchParamsMedicationPrescription;
begin
  for a := low(TSearchParamsMedicationPrescription) to high(TSearchParamsMedicationPrescription) do
  begin
    assert(CHECK_TSearchParamsMedicationPrescription[a] = a);
    indexes.add(frtMedicationPrescription, CODES_TSearchParamsMedicationPrescription[a], DESC_TSearchParamsMedicationPrescription[a], TYPES_TSearchParamsMedicationPrescription[a], TARGETS_TSearchParamsMedicationPrescription[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedicationPrescription(key : integer; id : String; context : TFhirResource; resource: TFhirMedicationPrescription);
var
  i : integer;
begin
  index(frtMedicationPrescription, key, 0, resource.statusElement, 'http://hl7.org/fhir/medication-prescription-status', 'status');
  index(context, frtMedicationPrescription, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(context, frtMedicationPrescription, key, 0, resource.Encounter, 'encounter');
  index(context, frtMedicationPrescription, key, 0, resource.medication, 'medication');
  for i := 0 to resource.identifierList.Count - 1 do
    index(frtMedicationPrescription, key, 0, resource.identifierList[i], 'identifier');
  index(frtMedicationPrescription, key, 0, resource.dateWrittenElement, 'datewritten');
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedicationDispense : Array[TSearchParamsMedicationDispense] of TSearchParamsMedicationDispense = ( spMedicationDispense__id, spMedicationDispense__Language, spMedicationDispense_Destination, spMedicationDispense_Dispenser, spMedicationDispense_Identifier, spMedicationDispense_Medication, spMedicationDispense_Patient, spMedicationDispense_Prescription, spMedicationDispense_ResponsibleParty, spMedicationDispense_Status, spMedicationDispense_Type, spMedicationDispense_WhenHandedOver, spMedicationDispense_WhenPrepared);
  {$ELSE}
  CHECK_TSearchParamsMedicationDispense : Array[TSearchParamsMedicationDispense] of TSearchParamsMedicationDispense = ( spMedicationDispense__id, spMedicationDispense__language, spMedicationDispense__lastUpdated, spMedicationDispense__profile, spMedicationDispense__security, spMedicationDispense__tag,
     spMedicationDispense_Destination, spMedicationDispense_Dispenser, spMedicationDispense_Identifier, spMedicationDispense_Medication, spMedicationDispense_Patient, spMedicationDispense_Prescription, spMedicationDispense_ResponsibleParty, spMedicationDispense_Status, spMedicationDispense_Type, spMedicationDispense_WhenHandedOver, spMedicationDispense_WhenPrepared);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesMedicationDispense;
var
  a : TSearchParamsMedicationDispense;
begin
  for a := low(TSearchParamsMedicationDispense) to high(TSearchParamsMedicationDispense) do
  begin
    assert(CHECK_TSearchParamsMedicationDispense[a] = a);
    indexes.add(frtMedicationDispense, CODES_TSearchParamsMedicationDispense[a], DESC_TSearchParamsMedicationDispense[a], TYPES_TSearchParamsMedicationDispense[a], TARGETS_TSearchParamsMedicationDispense[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedicationDispense(key : integer; id : String; context : TFhirResource; resource: TFhirMedicationDispense);
var
  i, j : integer;
begin
  index(frtMedicationDispense, key, 0, resource.statusElement, 'http://hl7.org/fhir/medication-dispense-status', 'status');
  index(context, frtMedicationDispense, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(context, frtMedicationDispense, key, 0, resource.dispenser, 'dispenser');
  index(frtMedicationDispense, key, 0, resource.identifier, 'identifier');
  for i := 0 to resource.authorizingPrescriptionList.Count - 1 do
    index(context, frtMedicationDispense, key, 0, resource.authorizingPrescriptionList[i], 'prescription');
  for j := 0 to resource.dispenseList.count - 1 do
  begin
    index(frtMedicationDispense, key, 0, resource.dispenseList[j].identifier, 'identifier');
    index(context, frtMedicationDispense, key, 0, resource.dispenseList[j].destination, 'destination');
    index(context, frtMedicationDispense, key, 0, resource.dispenseList[j].medication, 'medication');
    index(frtMedicationDispense, key, 0, resource.dispenseList[j].type_, 'type');
    index(frtMedicationDispense, key, 0, resource.dispenseList[j].whenPreparedElement, 'whenPrepared');
    index(frtMedicationDispense, key, 0, resource.dispenseList[j].whenHandedOverElement, 'whenHandedOver');
  end;
  if resource.substitution <> nil then
  begin
    for i := 0 to resource.substitution.responsiblePartyList.count - 1 do
      index(context, frtMedicationDispense, key, 0, resource.substitution.responsiblePartyList[i], 'dispenser');
  end;
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedicationStatement : Array[TSearchParamsMedicationStatement] of TSearchParamsMedicationStatement = ( spMedicationStatement__id, spMedicationStatement__Language, spMedicationStatement_Device, spMedicationStatement_Identifier, spMedicationStatement_Medication, spMedicationStatement_Patient, spMedicationStatement_When_given);
  {$ELSE}
  CHECK_TSearchParamsMedicationStatement : Array[TSearchParamsMedicationStatement] of TSearchParamsMedicationStatement = ( spMedicationStatement__id, spMedicationStatement__language, spMedicationStatement__lastUpdated, spMedicationStatement__profile, spMedicationStatement__security, spMedicationStatement__tag,
     spMedicationStatement_Device, spMedicationStatement_Identifier, spMedicationStatement_Medication, spMedicationStatement_Patient, spMedicationStatement_When_given);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesMedicationStatement;
var
  a : TSearchParamsMedicationStatement;
begin
  for a := low(TSearchParamsMedicationStatement) to high(TSearchParamsMedicationStatement) do
  begin
    assert(CHECK_TSearchParamsMedicationStatement[a] = a);
    indexes.add(frtMedicationStatement, CODES_TSearchParamsMedicationStatement[a], DESC_TSearchParamsMedicationStatement[a], TYPES_TSearchParamsMedicationStatement[a], TARGETS_TSearchParamsMedicationStatement[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedicationStatement(key : integer; id : String; context : TFhirResource; resource: TFhirMedicationStatement);
var
  i : integer;
begin
  for i := 0 to resource.identifierList.Count - 1 do
    index(frtMedicationStatement, key, 0, resource.identifierList[i], 'identifier');
  index(context, frtMedicationStatement, key, 0, resource.medication, 'medication');
  index(context, frtMedicationStatement, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.deviceList.Count - 1 do
    index(context, frtMedicationStatement, key, 0, resource.deviceList[i], 'device');
  index(frtMedicationStatement, key, 0, resource.whenGiven, 'when-given');
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsList : Array[TSearchParamsList] of TSearchParamsList = ( spList__id, spList__Language, spList_Code, spList_Date, spList_Empty_reason, spList_Item, spList_Source, spList_Subject);
  {$ELSE}
  CHECK_TSearchParamsList : Array[TSearchParamsList] of TSearchParamsList = ( spList__id, spList__language, spList__lastUpdated, spList__profile, spList__security, spList__tag,
     spList_Code, spList_Date, spList_Empty_reason, spList_Item, spList_Patient, spList_Source, spList_Subject);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesList;
var
  a : TSearchParamsList;
begin
  for a := low(TSearchParamsList) to high(TSearchParamsList) do
  begin
    assert(CHECK_TSearchParamsList[a] = a);
    indexes.add(frtList, CODES_TSearchParamsList[a], DESC_TSearchParamsList[a], TYPES_TSearchParamsList[a], TARGETS_TSearchParamsList[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesList(key : integer; id : String; context : TFhirResource; resource: TFhirList);
var
  i : integer;
begin
  index(context, frtList, key, 0, resource.source, 'source');
  for i := 0 to resource.entryList.count - 1 do
    index(context, frtList, key, 0, resource.entryList[i].item, 'item');
  index(frtList, key, 0, resource.emptyReason, 'empty-reason');
  index(frtList, key, 0, resource.dateElement, 'date');
  index(frtList, key, 0, resource.codeElement, 'code');
  index(context, frtList, key, 0, resource.subject, 'subject');
  index(context, frtList, key, 0, resource.subject, 'patient');
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsCarePlan : Array[TSearchParamsCarePlan] of TSearchParamsCarePlan = ( spCarePlan__id,  spCarePlan__Language,  spCarePlan_Activitycode, spCarePlan_Activitydate, spCarePlan_Activitydetail, spCarePlan_Condition, spCarePlan_Date, spCarePlan_Participant, spCarePlan_Patient);
  {$ELSE}
  CHECK_TSearchParamsCarePlan : Array[TSearchParamsCarePlan] of TSearchParamsCarePlan = ( spCarePlan__id, spCarePlan__language, spCarePlan__lastUpdated, spCarePlan__profile, spCarePlan__security, spCarePlan__tag,
    spCarePlan_Activitycode, spCarePlan_Activitydate, spCarePlan_Activitydetail, spCarePlan_Condition, spCarePlan_Date, spCarePlan_Participant, spCarePlan_Patient);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesCarePlan;
var
  a : TSearchParamsCarePlan;
begin
  for a := low(TSearchParamsCarePlan) to high(TSearchParamsCarePlan) do
  begin
    assert(CHECK_TSearchParamsCarePlan[a] = a);
    indexes.add(frtCarePlan, CODES_TSearchParamsCarePlan[a], DESC_TSearchParamsCarePlan[a], TYPES_TSearchParamsCarePlan[a], TARGETS_TSearchParamsCarePlan[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCarePlan(key: integer; id : String; context : TFhirResource; resource: TFhirCarePlan);
var
  i : integer;
begin
  index(context, frtCareplan, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.concernList.Count - 1 do
    index(context, frtCareplan, key, 0, resource.concernList[i], 'condition');
  index(frtCareplan, key, 0, resource.period, 'date');
  for i := 0 to resource.participantList.Count - 1 do
    index(context, frtCareplan, key, 0, resource.participantList[i].member, 'participant');
  for i := 0 to resource.activityList.Count - 1 do
    if resource.activityList[i].simple <> nil then
    begin
      index(frtCareplan, key, 0, resource.activityList[i].simple.code, 'activitycode');
      index(context, frtCareplan, key, 0, resource.activityList[i].detail, 'activitydetail');
      if (resource.activityList[i].simple.scheduled is TFhirTiming) then
        index(frtCareplan, key, 0, TFhirTiming(resource.activityList[i].simple.scheduled), 'activitydate')
      else if (resource.activityList[i].simple.scheduled is TFhirPeriod) then
        index(frtCareplan, key, 0, TFhirPeriod(resource.activityList[i].simple.scheduled), 'activitydate');
    end;
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsImagingStudy : Array[TSearchParamsImagingStudy] of TSearchParamsImagingStudy = ( spImagingStudy__id,  spImagingStudy__Language,  spImagingStudy_Accession,  spImagingStudy_Bodysite,  spImagingStudy_Date,  spImagingStudy_Dicom_Class,  spImagingStudy_Modality,  spImagingStudy_Series,  spImagingStudy_Size,  spImagingStudy_Study,  spImagingStudy_Subject,  spImagingStudy_Uid);
  {$ELSE}
  CHECK_TSearchParamsImagingStudy : Array[TSearchParamsImagingStudy] of TSearchParamsImagingStudy = ( spImagingStudy__id, spImagingStudy__language, spImagingStudy__lastUpdated, spImagingStudy__profile, spImagingStudy__security, spImagingStudy__tag,
    spImagingStudy_Accession, spImagingStudy_Bodysite, spImagingStudy_Dicom_class, spImagingStudy_Modality, spImagingStudy_Patient, spImagingStudy_Series, spImagingStudy_Size, spImagingStudy_Started, spImagingStudy_Study, spImagingStudy_Uid);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesImagingStudy;
var
  a : TSearchParamsImagingStudy;
begin
  for a := low(TSearchParamsImagingStudy) to high(TSearchParamsImagingStudy) do
  begin
    assert(CHECK_TSearchParamsImagingStudy[a] = a);
    indexes.add(frtImagingStudy, CODES_TSearchParamsImagingStudy[a], DESC_TSearchParamsImagingStudy[a], TYPES_TSearchParamsImagingStudy[a], TARGETS_TSearchParamsImagingStudy[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesImagingStudy(key: integer; id : String; context : TFhirResource; resource: TFhirImagingStudy);
var
  i, j : integer;
  series : TFhirImagingStudySeries;
  image : TFhirImagingStudySeriesInstance;
begin
  {$IFDEF FHIR-DSTU}
  index(context, frtImagingStudy, key, 0, resource.subject, 'subject');
  index(frtImagingStudy, key, 0, resource.dateTimeElement, 'date');
  index(frtImagingStudy, key, 0, resource.accessionNo, 'accession');
  patientCompartment(key, resource.subject);
  {$ELSE}
  index(context, frtImagingStudy, key, 0, resource.patient, 'patient');
  index(frtImagingStudy, key, 0, resource.startedElement, 'started');
  index(frtImagingStudy, key, 0, resource.accession, 'accession');
  patientCompartment(key, resource.patient);
  {$ENDIF}
  index(frtImagingStudy, key, 0, resource.uidElement, 'study');
  for i := 0 to resource.seriesList.count -1 do
  begin
    series := resource.seriesList[i];
    index(frtImagingStudy, key, 0, series.uidElement, 'series');
    index(frtImagingStudy, key, 0, series.ModalityElement, 'http://nema.org/dicom/dcid', 'modality');
//    index(frtImagingStudy, key, 0, resource., 'size');
    index(frtImagingStudy, key, 0, series.bodySite, 'bodySite');
    for j := 0 to series.instanceList.count - 1 do
    begin
      image := series.instanceList[j];
      index(frtImagingStudy, key, 0, image.uidElement, 'uid');
      index(frtImagingStudy, key, 0, image.sopclassElement, 'dicom-class');
    end;
  end;
end;


const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsImmunization : Array[TSearchParamsImmunization] of TSearchParamsImmunization = ( spImmunization__id, spImmunization__Language, spImmunization_Date, spImmunization_Dose_sequence, spImmunization_Identifier, spImmunization_Location, spImmunization_Lot_number, spImmunization_Manufacturer, spImmunization_Performer, spImmunization_Reaction, spImmunization_Reaction_date, spImmunization_Reason, spImmunization_Refusal_reason, spImmunization_Refused, spImmunization_Requester, spImmunization_Subject, spImmunization_Vaccine_type);
  {$ELSE}
  CHECK_TSearchParamsImmunization : Array[TSearchParamsImmunization] of TSearchParamsImmunization = ( spImmunization__id, spImmunization__language, spImmunization__lastUpdated, spImmunization__profile, spImmunization__security, spImmunization__tag,
     spImmunization_Date, spImmunization_Dose_sequence, spImmunization_Identifier, spImmunization_Location, spImmunization_Lot_number, spImmunization_Manufacturer, spImmunization_Patient, spImmunization_Performer, spImmunization_Reaction, spImmunization_Reaction_date, spImmunization_Reason, spImmunization_Refusal_reason, spImmunization_Refused, spImmunization_Requester, spImmunization_Subject, spImmunization_Vaccine_type);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesImmunization;
var
  a : TSearchParamsImmunization;
begin
  for a := low(TSearchParamsImmunization) to high(TSearchParamsImmunization) do
  begin
    assert(CHECK_TSearchParamsImmunization[a] = a);
    indexes.add(frtImmunization, CODES_TSearchParamsImmunization[a], DESC_TSearchParamsImmunization[a], TYPES_TSearchParamsImmunization[a], TARGETS_TSearchParamsImmunization[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesImmunization(key: integer; id : String; context : TFhirResource; resource: TFhirImmunization);
var
  i : integer;
begin
  index(frtImmunization, key, 0, resource.vaccineType, 'vaccine-type');
  index(frtImmunization, key, 0, resource.dateElement, 'date');
  if resource.explanation <> nil then
  begin
    for i := 0 to resource.explanation.refusalReasonList.count - 1 do
      index(frtImmunization, key, 0, resource.explanation.refusalReasonList[i], 'refusal-reason');
    for i := 0 to resource.explanation.reasonList.count - 1 do
      index(frtImmunization, key, 0, resource.explanation.reasonList[i], 'reason');
  end;
  for i := 0 to resource.identifierList.count - 1 do
      index(frtImmunization, key, 0, resource.identifierList[i], 'identifier');
  index(frtImmunization, key, 0, resource.lotNumberElement, 'lot-number');
  index(frtImmunization, key, 0, resource.refusedIndicator, 'refused');
  index(context, frtImmunization, key, 0, resource.manufacturer, 'manufacturer');
  index(context, frtImmunization, key, 0, resource.location, 'location');
  index(context, frtImmunization, key, 0, resource.performer, 'performer');
  index(context, frtImmunization, key, 0, resource.requester, 'requester');
  index(context, frtImmunization, key, 0, resource.subject, 'subject');
  index(context, frtImmunization, key, 0, resource.subject, 'patient');
  for i := 0 to resource.reactionList.count - 1 do
  begin
    index(context, frtImmunization, key, 0, resource.reactionList[i].detail, 'reaction');
    index(frtImmunization, key, 0, resource.reactionList[i].dateElement, 'reaction-date');
  end;
  for i := 0 to resource.vaccinationProtocolList.count - 1 do
    index(frtImmunization, key, 0, resource.vaccinationProtocolList[i].doseSequenceElement, 'dose-sequence');
  patientCompartment(key, resource.subject);
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsOrder : Array[TSearchParamsOrder] of TSearchParamsOrder = ( spOrder__id,  spOrder__Language,  spOrder_Authority,  spOrder_Date,  spOrder_Detail,  spOrder_Source,  spOrder_Subject,  spOrder_Target,  spOrder_When,  spOrder_When_code);
  {$ELSE}
  CHECK_TSearchParamsOrder : Array[TSearchParamsOrder] of TSearchParamsOrder = ( spOrder__id, spOrder__language, spOrder__lastUpdated, spOrder__profile, spOrder__security, spOrder__tag,
    spOrder_Authority, spOrder_Date, spOrder_Detail, spOrder_Patient, spOrder_Source, spOrder_Subject, spOrder_Target, spOrder_When, spOrder_When_code);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesOrder;
var
  a : TSearchParamsOrder;
begin
  for a := low(TSearchParamsOrder) to high(TSearchParamsOrder) do
  begin
    assert(CHECK_TSearchParamsOrder[a] = a);
    indexes.add(frtOrder, CODES_TSearchParamsOrder[a], DESC_TSearchParamsOrder[a], TYPES_TSearchParamsOrder[a], TARGETS_TSearchParamsOrder[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOrder(key: integer; id : String; context : TFhirResource; resource: TFhirOrder);
var
  i : integer;
begin
  index(frtOrder, key, 0, resource.dateElement, 'date');
  index(context, frtOrder, key, 0, resource.subject, 'subject');
  index(context, frtOrder, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(context, frtOrder, key, 0, resource.source, 'source');
  index(context, frtOrder, key, 0, resource.target, 'target');
  index(context, frtOrder, key, 0, resource.authority, 'authority');
  if resource.when <> nil then
  begin
    index(frtOrder, key, 0, resource.when.code, 'when_code');
    index(frtOrder, key, 0, resource.when.schedule, 'when');
  end;
  for i := 0 to resource.detailList.count - 1 do
    index(context, frtOrder, key, 0, resource.detailList[i], 'detail');
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsOrderResponse : Array[TSearchParamsOrderResponse] of TSearchParamsOrderResponse = ( spOrderResponse__id, spOrderResponse__Language, spOrderResponse_Code, spOrderResponse_Date, spOrderResponse_Fulfillment, spOrderResponse_Request, spOrderResponse_Who);
  {$ELSE}
  CHECK_TSearchParamsOrderResponse : Array[TSearchParamsOrderResponse] of TSearchParamsOrderResponse = ( spOrderResponse__id, spOrderResponse__language, spOrderResponse__lastUpdated, spOrderResponse__profile, spOrderResponse__security, spOrderResponse__tag,
     spOrderResponse_Code, spOrderResponse_Date, spOrderResponse_Fulfillment, spOrderResponse_Patient, spOrderResponse_Request, spOrderResponse_Who);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesOrderResponse;
var
  a : TSearchParamsOrderResponse;
begin
  for a := low(TSearchParamsOrderResponse) to high(TSearchParamsOrderResponse) do
  begin
    assert(CHECK_TSearchParamsOrderResponse[a] = a);
    indexes.add(frtOrderResponse, CODES_TSearchParamsOrderResponse[a], DESC_TSearchParamsOrderResponse[a], TYPES_TSearchParamsOrderResponse[a], TARGETS_TSearchParamsOrderResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOrderResponse(key: integer; id : String; context : TFhirResource; resource: TFhirOrderResponse);
var
  i : integer;
begin
  index(context, frtOrderResponse, key, 0, resource.request, 'request');
  index(frtOrderResponse, key, 0, resource.dateElement, 'date');
  index(context, frtOrderResponse, key, 0, resource.who, 'who');
  index(frtOrderResponse, key, 0, resource.codeElement, 'http://hl7.org/fhir/order-outcome-code', 'code');
  for i := 0 to resource.fulfillmentList.count - 1 do
    index(context, frtOrderResponse, key, 0, resource.fulfillmentList[i], 'fulfillment');
  // todo: patient
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsMedia : Array[TSearchParamsMedia] of TSearchParamsMedia = ( spMedia__id,  spMedia__Language,  spMedia_Date, spMedia_Identifier, spMedia_Operator, spMedia_Subject, spMedia_Subtype, spMedia_Type, spMedia_View);
  {$ELSE}
  CHECK_TSearchParamsMedia : Array[TSearchParamsMedia] of TSearchParamsMedia = ( spMedia__id, spMedia__language, spMedia__lastUpdated, spMedia__profile, spMedia__security, spMedia__tag,
    spMedia_Created, spMedia_Identifier, spMedia_Operator, spMedia_Patient, spMedia_Subject, spMedia_Subtype, spMedia_Type, spMedia_View);
  {$ENDIF}


procedure TFhirIndexManager.buildIndexesMedia;
var
  a : TSearchParamsMedia;
begin
  for a := low(TSearchParamsMedia) to high(TSearchParamsMedia) do
  begin
    assert(CHECK_TSearchParamsMedia[a] = a);
    indexes.add(frtMedia, CODES_TSearchParamsMedia[a], DESC_TSearchParamsMedia[a], TYPES_TSearchParamsMedia[a], TARGETS_TSearchParamsMedia[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesMedia(key: integer; id : String; context : TFhirResource; resource: TFhirMedia);
var
  i : integer;
begin
  index(context, frtMedia, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  for i := 0 to resource.identifierList.count - 1 do
    index(frtMedia, key, 0, resource.identifierList[i], 'identifier');
  index(context, frtMedia, key, 0, resource.operator, 'operator');
  index(frtMedia, key, 0, resource.type_Element, 'http://hl7.org/fhir/media-type', 'type');
  index(frtMedia, key, 0, resource.subtype, 'subtype');
  {$IFDEF FHIR-DSTU}
  index(frtMedia, key, 0, resource.dateTimeElement, 'date');
  {$ELSE}
  index(frtMedia, key, 0, resource.createdElement, 'created');
  {$ENDIF}
//  index(frtMedia, key, 0, resource.size, 'size');
  index(frtMedia, key, 0, resource.view, 'view');
end;



const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsFamilyHistory : Array[TSearchParamsFamilyHistory] of TSearchParamsFamilyHistory = ( spFamilyHistory__id,  spFamilyHistory__Language,  spFamilyHistory_Subject);
  {$ELSE}
  CHECK_TSearchParamsFamilyHistory : Array[TSearchParamsFamilyHistory] of TSearchParamsFamilyHistory = ( spFamilyHistory__id, spFamilyHistory__language, spFamilyHistory__lastUpdated, spFamilyHistory__profile, spFamilyHistory__security, spFamilyHistory__tag,
    spFamilyHistory_Date, spFamilyHistory_Patient);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesFamilyHistory;
var
  a : TSearchParamsFamilyHistory;
begin
  for a := low(TSearchParamsFamilyHistory) to high(TSearchParamsFamilyHistory) do
  begin
    assert(CHECK_TSearchParamsFamilyHistory[a] = a);
    indexes.add(frtFamilyHistory, CODES_TSearchParamsFamilyHistory[a], DESC_TSearchParamsFamilyHistory[a], TYPES_TSearchParamsFamilyHistory[a], TARGETS_TSearchParamsFamilyHistory[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesFamilyHistory(key: integer; id : String; context : TFhirResource; resource: TFhirFamilyHistory);
begin
  {$IFNDEF FHIR-DSTU}
  index(context, frtFamilyHistory, key, 0, resource.patient, 'patient');
  index(frtFamilyHistory, key, 0, resource.dateElement, 'date');
  patientCompartment(key, resource.patient);
  {$ELSE}
  index(context, frtFamilyHistory, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  {$ENDIF}
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsProcedure : Array[TSearchParamsProcedure] of TSearchParamsProcedure = ( spProcedure__id,  spProcedure__Language,  spProcedure_Date, spProcedure_Subject, spProcedure_Type);
  {$ELSE}
  CHECK_TSearchParamsProcedure : Array[TSearchParamsProcedure] of TSearchParamsProcedure = ( spProcedure__id, spProcedure__language, spProcedure__lastUpdated, spProcedure__profile, spProcedure__security, spProcedure__tag,
     spProcedure_Date, spProcedure_Patient, spProcedure_Type);
  {$ENDIF}

procedure TFhirIndexManager.buildIndexesProcedure;
var
  a : TSearchParamsProcedure;
begin
  for a := low(TSearchParamsProcedure) to high(TSearchParamsProcedure) do
  begin
    assert(CHECK_TSearchParamsProcedure[a] = a);
    indexes.add(frtProcedure, CODES_TSearchParamsProcedure[a], DESC_TSearchParamsProcedure[a], TYPES_TSearchParamsProcedure[a], TARGETS_TSearchParamsProcedure[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesProcedure(key: integer; id : String; context : TFhirResource; resource: TFhirProcedure);
begin
  index(frtProcedure, key, 0, resource.date, 'date');
  {$IFDEF FHIR-DSTU}
  index(context, frtProcedure, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  {$ELSE}
  index(context, frtProcedure, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  {$ENDIF}
  index(frtProcedure, key, 0, resource.type_, 'type');
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsSpecimen : Array[TSearchParamsSpecimen] of TSearchParamsSpecimen = ( spSpecimen__id, spSpecimen__Language, spSpecimen_Subject);
  {$ELSE}
  CHECK_TSearchParamsSpecimen : Array[TSearchParamsSpecimen] of TSearchParamsSpecimen = ( spSpecimen__id, spSpecimen__language, spSpecimen__lastUpdated, spSpecimen__profile, spSpecimen__security, spSpecimen__tag,
    spSpecimen_Accession, spSpecimen_Collected, spSpecimen_Collector, spSpecimen_Container, spSpecimen_Containerid, spSpecimen_Identifier, spSpecimen_Patient, spSpecimen_Site, spSpecimen_Source, spSpecimen_Subject, spSpecimen_Type);

  {$ENDIF}

procedure TFhirIndexManager.buildIndexesSpecimen;
var
  a : TSearchParamsSpecimen;
begin
  for a := low(TSearchParamsSpecimen) to high(TSearchParamsSpecimen) do
  begin
    assert(CHECK_TSearchParamsSpecimen[a] = a);
    indexes.add(frtSpecimen, CODES_TSearchParamsSpecimen[a], DESC_TSearchParamsSpecimen[a], TYPES_TSearchParamsSpecimen[a], TARGETS_TSearchParamsSpecimen[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSpecimen(key: integer; id : String; context : TFhirResource; resource: TFhirSpecimen);
var
  i, j : integer;
begin
  index(context, frtSpecimen, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  {$IFNDEF FHIR-DSTU}
  index(context, frtSpecimen, key, 0, resource.subject, 'patient');
  index(frtSpecimen, key, 0, resource.accessionIdentifier, 'accession');
  index(frtSpecimen, key, 0, resource.type_, 'type');
  index(frtSpecimen, key, 0, resource.identifierList, 'identifier');
  if (resource.collection <> nil) then
  begin
    if resource.collection.collected is TFhirPeriod then
      index(frtSpecimen, key, 0, TFhirPeriod(resource.collection.collected), 'collected')
    else
      index(frtSpecimen, key, 0, TFhirDateTime(resource.collection.collected), 'collected');
    index(context, frtSpecimen, key, 0, resource.collection.collector, 'collector');
    index(frtSpecimen, key, 0, resource.collection.sourceSite, 'site');
  end;
  for i := 0 to resource.containerList.Count - 1 do
  begin
    index(frtSpecimen, key, 0, resource.containerList[i].type_, 'container');
    index(frtSpecimen, key, 0, resource.containerList[i].identifierList, 'containerid');
  end;
  for i := 0 to resource.sourceList.Count - 1  do
    for j := 0 to resource.sourceList[i].targetList.Count - 1  do
      index(context, frtSpecimen, key, 0, resource.sourceList[i].targetList[j], 'source');
  {$ENDIF}
end;

const
  {$IFDEF FHIR-DSTU}
  CHECK_TSearchParamsImmunizationRecommendation : Array[TSearchParamsImmunizationRecommendation] of TSearchParamsImmunizationRecommendation = ( spImmunizationRecommendation__id, spImmunizationRecommendation__Language, spImmunizationRecommendation_Date, spImmunizationRecommendation_Dose_number, spImmunizationRecommendation_Dose_sequence, spImmunizationRecommendation_Identifier, spImmunizationRecommendation_Information, spImmunizationRecommendation_Status, spImmunizationRecommendation_Subject, spImmunizationRecommendation_Support, spImmunizationRecommendation_Vaccine_type);
  {$ELSE}
  CHECK_TSearchParamsImmunizationRecommendation : Array[TSearchParamsImmunizationRecommendation] of TSearchParamsImmunizationRecommendation = ( spImmunizationRecommendation__id, spImmunizationRecommendation__language, spImmunizationRecommendation__lastUpdated, spImmunizationRecommendation__profile, spImmunizationRecommendation__security, spImmunizationRecommendation__tag,
     spImmunizationRecommendation_Date, spImmunizationRecommendation_Dose_number, spImmunizationRecommendation_Dose_sequence, spImmunizationRecommendation_Identifier, spImmunizationRecommendation_Information, spImmunizationRecommendation_Patient, spImmunizationRecommendation_Status, spImmunizationRecommendation_Subject, spImmunizationRecommendation_Support, spImmunizationRecommendation_Vaccine_type);
  {$ENDIF}



procedure TFhirIndexManager.buildIndexesImmunizationRecommendation;
var
  a : TSearchParamsImmunizationRecommendation;
begin
  for a := low(TSearchParamsImmunizationRecommendation) to high(TSearchParamsImmunizationRecommendation) do
  begin
    assert(CHECK_TSearchParamsImmunizationRecommendation[a] = a);
    indexes.add(frtImmunizationRecommendation, CODES_TSearchParamsImmunizationRecommendation[a], DESC_TSearchParamsImmunizationRecommendation[a], TYPES_TSearchParamsImmunizationRecommendation[a], TARGETS_TSearchParamsImmunizationRecommendation[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesImmunizationRecommendation(key: integer; id : String; context : TFhirResource; resource: TFhirImmunizationRecommendation);
var
  i,j  : integer;
begin
  patientCompartment(key, resource.subject);

  index(context, frtImmunizationRecommendation, key, 0, resource.subject, 'subject');
  {$IFNDEF FHIR-DSTU}
  index(context, frtImmunizationRecommendation, key, 0, resource.subject, 'patient');
  {$ENDIF}

  for i := 0 to resource.identifierList.count - 1 do
    index(frtImmunizationRecommendation, key, 0, resource.identifierList[i], 'identifier');

  for i := 0 to resource.recommendationList.count - 1 do
  begin
    index(frtImmunizationRecommendation, key, 0, resource.recommendationList[i].dateElement, 'date');
    index(frtImmunizationRecommendation, key, 0, resource.recommendationList[i].vaccineType, 'vaccine-type');
    index(frtImmunizationRecommendation, key, 0, resource.recommendationList[i].doseNumberElement, 'dose-number');
    index(frtImmunizationRecommendation, key, 0, resource.recommendationList[i].forecastStatus, 'status');
    if resource.recommendationList[i].protocol <> nil then
      index(frtImmunizationRecommendation, key, 0, resource.recommendationList[i].protocol.doseSequenceElement, 'dose-sequence');
    for j := 0 to resource.recommendationList[i].supportingPatientInformationList.Count - 1 do
      index(context, frtImmunizationRecommendation, key, 0, resource.recommendationList[i].supportingPatientInformationList[j], 'information');
    for j := 0 to resource.recommendationList[i].supportingImmunizationList.Count - 1 do
      index(context, frtImmunizationRecommendation, key, 0, resource.recommendationList[i].supportingImmunizationList[j], 'support');
  end;
end;


{$IFDEF FHIR-DSTU}
Const
  CHECK_TSearchParamsQuestionnaire : Array[TSearchParamsQuestionnaire] of TSearchParamsQuestionnaire = (spQuestionnaire__id, spQuestionnaire__language, spQuestionnaire_Author, spQuestionnaire_Authored, spQuestionnaire_Encounter, spQuestionnaire_Identifier, spQuestionnaire_Name, spQuestionnaire_Status, spQuestionnaire_Subject);

procedure TFhirIndexManager.buildIndexesQuestionnaire;
var
  a : TSearchParamsQuestionnaire;
begin
  for a := low(TSearchParamsQuestionnaire) to high(TSearchParamsQuestionnaire) do
  begin
    assert(CHECK_TSearchParamsQuestionnaire[a] = a);
    indexes.add(frtQuestionnaire, CODES_TSearchParamsQuestionnaire[a], DESC_TSearchParamsQuestionnaire[a], TYPES_TSearchParamsQuestionnaire[a], TARGETS_TSearchParamsQuestionnaire[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesQuestionnaire(key: integer; id : String; context : TFhirResource; resource: TFhirQuestionnaire);
begin
  index(context, frtQuestionnaire, key, 0, resource.author, 'author');
  index(frtQuestionnaire, key, 0, resource.authoredElement, 'authored');
  index(frtQuestionnaire, key, 0, resource.statusElement, 'http://hl7.org/fhir/questionnaire-status', 'status');
  index(context, frtQuestionnaire, key, 0, resource.encounter, 'encounter');
  index(context, frtQuestionnaire, key, 0, resource.subject, 'subject');
  index(frtQuestionnaire, key, 0, resource.identifierList, 'identifier');
  index(frtQuestionnaire, key, 0, resource.name, 'name');
end;


{$ELSE}

Const
  CHECK_TSearchParamsQuestionnaire : Array[TSearchParamsQuestionnaire] of TSearchParamsQuestionnaire = ( spQuestionnaire__id, spQuestionnaire__language, spQuestionnaire__lastUpdated, spQuestionnaire__profile, spQuestionnaire__security, spQuestionnaire__tag,
     spQuestionnaire_Code, spQuestionnaire_Date, spQuestionnaire_Identifier, spQuestionnaire_Publisher, spQuestionnaire_Status, spQuestionnaire_Title, spQuestionnaire_Version);

procedure TFhirIndexManager.buildIndexesQuestionnaire;
var
  a : TSearchParamsQuestionnaire;
begin
  for a := low(TSearchParamsQuestionnaire) to high(TSearchParamsQuestionnaire) do
  begin
    assert(CHECK_TSearchParamsQuestionnaire[a] = a);
    indexes.add(frtQuestionnaire, CODES_TSearchParamsQuestionnaire[a], DESC_TSearchParamsQuestionnaire[a], TYPES_TSearchParamsQuestionnaire[a], TARGETS_TSearchParamsQuestionnaire[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesQuestionnaire(key: integer; id : String; context : TFhirResource; resource: TFhirQuestionnaire);
  procedure IndexGroup(group : TFhirQuestionnaireGroup);
  var
    i : integer;
  begin
    index(frtQuestionnaire, key, 0, group.conceptList, 'code');
    for I := 0 to group.groupList.Count - 1 do
      indexGroup(group.groupList[i]);
  end;
begin
  index(frtQuestionnaire, key, 0, resource.publisherElement, 'publisher');
  index(frtQuestionnaire, key, 0, resource.statusElement, 'http://hl7.org/fhir/questionnaire-status', 'status');
  index(frtQuestionnaire, key, 0, resource.identifierList, 'identifier');
  index(frtQuestionnaire, key, 0, resource.dateElement, 'date');
  index(frtQuestionnaire, key, 0, resource.versionElement, 'version');
  index(frtQuestionnaire, key, 0, resource.group.titleElement, 'title');
  IndexGroup(resource.group);
end;


Const
  CHECK_TSearchParamsQuestionnaireAnswers : Array[TSearchParamsQuestionnaireAnswers] of TSearchParamsQuestionnaireAnswers = (spQuestionnaireAnswers__id, spQuestionnaireAnswers__language, spQuestionnaireAnswers__lastUpdated, spQuestionnaireAnswers__profile, spQuestionnaireAnswers__security, spQuestionnaireAnswers__tag,
     spQuestionnaireAnswers_Author, spQuestionnaireAnswers_Authored, spQuestionnaireAnswers_Encounter, spQuestionnaireAnswers_Patient, spQuestionnaireAnswers_Questionnaire, spQuestionnaireAnswers_Status, spQuestionnaireAnswers_Subject);


procedure TFhirIndexManager.buildIndexesQuestionnaireAnswers;
var
  a : TSearchParamsQuestionnaireAnswers;
begin
  for a := low(TSearchParamsQuestionnaireAnswers) to high(TSearchParamsQuestionnaireAnswers) do
  begin
    assert(CHECK_TSearchParamsQuestionnaireAnswers[a] = a);
    indexes.add(frtQuestionnaireAnswers, CODES_TSearchParamsQuestionnaireAnswers[a], DESC_TSearchParamsQuestionnaireAnswers[a], TYPES_TSearchParamsQuestionnaireAnswers[a], TARGETS_TSearchParamsQuestionnaireAnswers[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesQuestionnaireAnswers(key: integer; id : String; context : TFhirResource; resource: TFhirQuestionnaireAnswers);
begin
  index(context, frtQuestionnaireAnswers, key, 0, resource.author, 'author');
  index(context, frtQuestionnaireAnswers, key, 0, resource.encounter, 'encounter');
  index(context, frtQuestionnaireAnswers, key, 0, resource.questionnaire, 'questionnaire');
  index(context, frtQuestionnaireAnswers, key, 0, resource.subject, 'subject');
  index(context, frtQuestionnaireAnswers, key, 0, resource.subject, 'patient');
  index(frtQuestionnaireAnswers, key, 0, resource.statusElement, 'http://hl7.org/fhir/questionnaire-answers-status', 'status');
  index(frtQuestionnaireAnswers, key, 0, resource.authoredElement, 'authored');
  patientCompartment(key, resource.subject);
  patientCompartment(key, resource.author);
end;



Const
  CHECK_TSearchParamsSlot : Array[TSearchParamsSlot] of TSearchParamsSlot = (spSlot__id, spSlot__language, spSlot__lastUpdated, spSlot__profile, spSlot__security, spSlot__tag,
     spSlot_Fbtype, spSlot_Schedule, spSlot_Slottype, spSlot_Start);

procedure TFhirIndexManager.buildIndexesSlot;
var
  a : TSearchParamsSlot;
begin
  for a := low(TSearchParamsSlot) to high(TSearchParamsSlot) do
  begin
    assert(CHECK_TSearchParamsSlot[a] = a);
    indexes.add(frtSlot, CODES_TSearchParamsSlot[a], DESC_TSearchParamsSlot[a], TYPES_TSearchParamsSlot[a], TARGETS_TSearchParamsSlot[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSlot(key: integer; id : String; context : TFhirResource; resource: TFhirSlot);
begin
  index(context, frtSlot, key, 0, resource.schedule, 'schedule');
  index(frtSlot, key, 0, resource.freeBusyTypeElement, 'http://hl7.org/fhir/slotstatus', 'fbtype');
  index(frtSlot, key, 0, resource.type_, 'slottype');
  index(frtSlot, key, 0, resource.startElement, 'start');
end;

Const
  CHECK_TSearchParamsAppointment : Array[TSearchParamsAppointment] of TSearchParamsAppointment = (spAppointment__id, spAppointment__language, spAppointment__lastUpdated, spAppointment__profile, spAppointment__security, spAppointment__tag,
     spAppointment_Actor, spAppointment_Date, spAppointment_Partstatus, spAppointment_Patient, spAppointment_Status);

procedure TFhirIndexManager.buildIndexesAppointment;
var
  a : TSearchParamsAppointment;
begin
  for a := low(TSearchParamsAppointment) to high(TSearchParamsAppointment) do
  begin
    assert(CHECK_TSearchParamsAppointment[a] = a);
    indexes.add(frtAppointment, CODES_TSearchParamsAppointment[a], DESC_TSearchParamsAppointment[a], TYPES_TSearchParamsAppointment[a], TARGETS_TSearchParamsAppointment[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesAppointment(key: integer; id : String; context : TFhirResource; resource: TFhirAppointment);
var
  i : integer;
begin
  index(frtAppointment, key, 0, resource.startElement, 'date');
  index(frtAppointment, key, 0, resource.statusElement, 'http://hl7.org/fhir/appointmentstatus', 'status');
  for i := 0 to resource.participantList.Count - 1 do
  begin
    index(frtAppointment, key, 0, resource.participantList[i].statusElement, 'http://hl7.org/fhir/participationstatus', 'partstatus');
    index(context, frtAppointment, key, 0, resource.participantList[i].actor, 'actor');
    index(context, frtAppointment, key, 0, resource.participantList[i].actor, 'patient');
    patientCompartment(key, resource.participantList[i].actor);
  end;
end;

Const
  CHECK_TSearchParamsSchedule : Array[TSearchParamsSchedule] of TSearchParamsSchedule = (spSchedule__id, spSchedule__language, spSchedule__lastUpdated, spSchedule__profile, spSchedule__security, spSchedule__tag,
     spSchedule_Actor, spSchedule_Date, spSchedule_Type);

procedure TFhirIndexManager.buildIndexesSchedule;
var
  a : TSearchParamsSchedule;
begin
  for a := low(TSearchParamsSchedule) to high(TSearchParamsSchedule) do
  begin
    assert(CHECK_TSearchParamsSchedule[a] = a);
    indexes.add(frtSchedule, CODES_TSearchParamsSchedule[a], DESC_TSearchParamsSchedule[a], TYPES_TSearchParamsSchedule[a], TARGETS_TSearchParamsSchedule[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSchedule(key: integer; id : String; context : TFhirResource; resource: TFhirSchedule);
var
  i : integer;
begin
  index(frtSchedule, key, 0, resource.planningHorizon, 'date');
  index(context, frtSchedule, key, 0, resource.actor, 'actor');
  for i := 0 to resource.type_List.Count - 1 do
    index(frtSchedule, key, 0, resource.type_List[i], 'type');
  patientCompartment(key, resource.actor);
end;

Const
  CHECK_TSearchParamsAppointmentResponse : Array[TSearchParamsAppointmentResponse] of TSearchParamsAppointmentResponse = (spAppointmentResponse__id, spAppointmentResponse__language, spAppointmentResponse__lastUpdated, spAppointmentResponse__profile, spAppointmentResponse__security, spAppointmentResponse__tag,
     spAppointmentResponse_Appointment, spAppointmentResponse_Partstatus, spAppointmentResponse_Subject);

procedure TFhirIndexManager.buildIndexesAppointmentResponse;
var
  a : TSearchParamsAppointmentResponse;
begin
  for a := low(TSearchParamsAppointmentResponse) to high(TSearchParamsAppointmentResponse) do
  begin
    assert(CHECK_TSearchParamsAppointmentResponse[a] = a);
    indexes.add(frtAppointmentResponse, CODES_TSearchParamsAppointmentResponse[a], DESC_TSearchParamsAppointmentResponse[a], TYPES_TSearchParamsAppointmentResponse[a], TARGETS_TSearchParamsAppointmentResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesAppointmentResponse(key: integer; id : String; context : TFhirResource; resource: TFhirAppointmentResponse);
var
  i : integer;
begin
  index(frtAppointmentResponse, key, 0, resource.participantStatusElement, 'http://hl7.org/fhir/participantstatus', 'partstatus');
  index(context, frtAppointmentResponse, key, 0, resource.appointment, 'appointment');
  for i := 0 to resource.individualList.Count - 1 do
  begin
    index(context, frtAppointmentResponse, key, 0, resource.individualList[i], 'subject');
    patientCompartment(key, resource.individualList[i]);
  end;
end;

Const
  CHECK_TSearchParamsHealthcareService : Array[TSearchParamsHealthcareService] of TSearchParamsHealthcareService = (spHealthcareService__id, spHealthcareService__language, spHealthcareService__lastUpdated, spHealthcareService__Profile, spHealthcareService__security, spHealthcareService__tag,
     spHealthcareService_Location, spHealthcareService_Name, spHealthcareService_Servicecategory, spHealthcareService_Servicetype);

procedure TFhirIndexManager.buildIndexesHealthcareService;
var
  a : TSearchParamsHealthcareService;
begin
  for a := low(TSearchParamsHealthcareService) to high(TSearchParamsHealthcareService) do
  begin
    assert(CHECK_TSearchParamsHealthcareService[a] = a);
    indexes.add(frtHealthcareService, CODES_TSearchParamsHealthcareService[a], DESC_TSearchParamsHealthcareService[a], TYPES_TSearchParamsHealthcareService[a], TARGETS_TSearchParamsHealthcareService[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesHealthcareService(key: integer; id : String; context : TFhirResource; resource: TFhirHealthcareService);
var
  i : integer;
begin
  index(frtHealthcareService, key, 0, resource.serviceNameElement, 'name');
  index(context, frtHealthcareService, key, 0, resource.locationElement, 'location');
  index(frtHealthcareService, key, 0, resource.serviceCategoryElement, 'servicecategory');
  for i := 0 to resource.serviceTypeList.Count - 1 do
    index(frtHealthcareService, key, 0, resource.serviceTypeList[i].type_Element, 'servicetype');
end;

Const
  CHECK_TSearchParamsDataElement : Array[TSearchParamsDataElement] of TSearchParamsDataElement = (spDataElement__id, spDataElement__language, spDataElement__lastUpdated, spDataElement__profile, spDataElement__security, spDataElement__tag,
     spDataElement_Category, spDataElement_Code, spDataElement_Date, spDataElement_Description, spDataElement_Identifier, spDataElement_Name, spDataElement_Publisher, spDataElement_Status, spDataElement_Version);

procedure TFhirIndexManager.buildIndexesDataElement;
var
  a : TSearchParamsDataElement;
begin
  for a := low(TSearchParamsDataElement) to high(TSearchParamsDataElement) do
  begin
    assert(CHECK_TSearchParamsDataElement[a] = a);
    indexes.add(frtDataElement, CODES_TSearchParamsDataElement[a], DESC_TSearchParamsDataElement[a], TYPES_TSearchParamsDataElement[a], TARGETS_TSearchParamsDataElement[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDataElement(key: integer; id : String; context : TFhirResource; resource: TFhirDataElement);
begin
  index(frtDataElement, key, 0, resource.categoryList, 'category');
  index(frtDataElement, key, 0, resource.codeList, 'code');
  index(frtDataElement, key, 0, resource.dateElement, 'date');
  index(frtDataElement, key, 0, resource.definitionElement, 'description');
  index(frtDataElement, key, 0, resource.identifierElement, 'identifier');
  index(frtDataElement, key, 0, resource.nameElement, 'name');
  index(frtDataElement, key, 0, resource.publisherElement, 'publisher');
  index(frtDataElement, key, 0, resource.statusElement, 'http://hl7.org/fhir/resource-observation-def-status', 'status');
  index(frtDataElement, key, 0, resource.versionElement, 'version');
end;

Const
  CHECK_TSearchParamsNamingSystem : Array[TSearchParamsNamingSystem] of TSearchParamsNamingSystem = (spNamingSystem__id, spNamingSystem__language, spNamingSystem__lastUpdated, spNamingSystem__profile, spNamingSystem__security, spNamingSystem__tag);


procedure TFhirIndexManager.buildIndexesNamingSystem;
var
  a : TSearchParamsNamingSystem;
begin
  for a := low(TSearchParamsNamingSystem) to high(TSearchParamsNamingSystem) do
  begin
    assert(CHECK_TSearchParamsNamingSystem[a] = a);
    indexes.add(frtNamingSystem, CODES_TSearchParamsNamingSystem[a], DESC_TSearchParamsNamingSystem[a], TYPES_TSearchParamsNamingSystem[a], TARGETS_TSearchParamsNamingSystem[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesNamingSystem(key: integer; id : String; context : TFhirResource; resource: TFhirNamingSystem);
begin
end;

Const
  CHECK_TSearchParamsSubscription : Array[TSearchParamsSubscription] of TSearchParamsSubscription = (spSubscription__id, spSubscription__language, spSubscription__lastUpdated, spSubscription__profile, spSubscription__security, spSubscription__tag,
     spSubscription_Contact, spSubscription_Criteria, spSubscription_Payload, spSubscription_Status, spSubscription_Tag, spSubscription_Type, spSubscription_Url);

procedure TFhirIndexManager.buildIndexesSubscription;
var
  a : TSearchParamsSubscription;
begin
  for a := low(TSearchParamsSubscription) to high(TSearchParamsSubscription) do
  begin
    assert(CHECK_TSearchParamsSubscription[a] = a);
    indexes.add(frtSubscription, CODES_TSearchParamsSubscription[a], DESC_TSearchParamsSubscription[a], TYPES_TSearchParamsSubscription[a], TARGETS_TSearchParamsSubscription[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSubscription(key: integer; id : String; context : TFhirResource; resource: TFhirSubscription);
var
  i : integer;
begin
  for i := 0 to resource.contactList.Count - 1 do
    index(frtSubscription, key, 0, resource.contactList[i], 'contact');
  index(frtSubscription, key, 0, resource.criteriaElement, 'criteria');
  index(frtSubscription, key, 0, resource.statusElement, 'http://hl7.org/fhir/subscription-status', 'status');
  for i := 0 to resource.tagList.Count - 1 do
    index(frtSubscription, key, 0, resource.tagList[i].termElement, 'tag');
  index(frtSubscription, key, 0, resource.channel.type_Element, 'http://hl7.org/fhir/subscription-channel-type', 'type');
  index(frtSubscription, key, 0, resource.channel.payloadElement, 'payload');
  index(frtSubscription, key, 0, resource.channel.urlElement, 'url');
end;

Const
  CHECK_TSearchParamsContraIndication : Array[TSearchParamsContraIndication] of TSearchParamsContraIndication = (spContraIndication__id, spContraIndication__language, spContraIndication__lastUpdated, spContraIndication__profile, spContraIndication__security, spContraIndication__tag,
     spContraindication_Category, spContraindication_Date, spContraindication_Identifier, spContraindication_Implicated, spContraindication_Patient);

procedure TFhirIndexManager.buildIndexesContraIndication;
var
  a : TSearchParamsContraIndication;
begin
  for a := low(TSearchParamsContraIndication) to high(TSearchParamsContraIndication) do
  begin
    assert(CHECK_TSearchParamsContraIndication[a] = a);
    indexes.add(frtContraIndication, CODES_TSearchParamsContraIndication[a], DESC_TSearchParamsContraIndication[a], TYPES_TSearchParamsContraIndication[a], TARGETS_TSearchParamsContraIndication[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesContraIndication(key: integer; id : String; context : TFhirResource; resource: TFhirContraIndication);
var
  i : integer;
begin
  index(frtContraIndication, key, 0, resource.category, 'category');
  index(frtContraIndication, key, 0, resource.dateElement, 'date');
  index(frtContraIndication, key, 0, resource.identifier, 'identifier');
  for i := 0 to resource.implicatedList.Count - 1 do
    index(context, frtContraIndication, key, 0, resource.patient, 'implicated');
  index(context, frtContraIndication, key, 0, resource.patient, 'patient');
end;

Const
  CHECK_TSearchParamsRiskAssessment : Array[TSearchParamsRiskAssessment] of TSearchParamsRiskAssessment = (spRiskAssessment__id, spRiskAssessment__language, spRiskAssessment__lastUpdated, spRiskAssessment__profile, spRiskAssessment__security, spRiskAssessment__tag,
     spRiskAssessment_Condition, spRiskAssessment_Date, spRiskAssessment_Identifier, spRiskAssessment_Method, spRiskAssessment_Patient, spRiskAssessment_Performer, spRiskAssessment_Subject);


procedure TFhirIndexManager.buildIndexesRiskAssessment;
var
  a : TSearchParamsRiskAssessment;
begin
  for a := low(TSearchParamsRiskAssessment) to high(TSearchParamsRiskAssessment) do
  begin
    assert(CHECK_TSearchParamsRiskAssessment[a] = a);
    indexes.add(frtRiskAssessment, CODES_TSearchParamsRiskAssessment[a], DESC_TSearchParamsRiskAssessment[a], TYPES_TSearchParamsRiskAssessment[a], TARGETS_TSearchParamsRiskAssessment[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesRiskAssessment(key: integer; id : String; context : TFhirResource; resource: TFhirRiskAssessment);
var
  i : integer;
begin
  index(frtRiskAssessment, key, 0, resource.dateElement, 'date');
  index(frtRiskAssessment, key, 0, resource.identifier, 'identifier');

  index(frtRiskAssessment, key, 0, resource.method, 'method');
  index(context, frtRiskAssessment, key, 0, resource.subject, 'subject');
  index(context, frtRiskAssessment, key, 0, resource.subject, 'patient');
  index(context, frtRiskAssessment, key, 0, resource.condition, 'condition');
  index(context, frtRiskAssessment, key, 0, resource.performer, 'performer');
end;

const
  CHECK_TSearchParamsOperationDefinition : Array[TSearchParamsOperationDefinition] of TSearchParamsOperationDefinition = ( spOperationDefinition__id, spOperationDefinition__language, spOperationDefinition__lastUpdated, spOperationDefinition__profile, spOperationDefinition__security, spOperationDefinition__tag,
     spOperationDefinition_Base, spOperationDefinition_Code, spOperationDefinition_Date, spOperationDefinition_Identifier, spOperationDefinition_Instance, spOperationDefinition_Kind, spOperationDefinition_Name, spOperationDefinition_Profile, spOperationDefinition_Publisher, spOperationDefinition_Status, spOperationDefinition_System, spOperationDefinition_Title, spOperationDefinition_Type, spOperationDefinition_Version);

procedure TFhirIndexManager.buildIndexesOperationDefinition;
var
  a : TSearchParamsOperationDefinition;
begin
  for a := low(TSearchParamsOperationDefinition) to high(TSearchParamsOperationDefinition) do
  begin
    assert(CHECK_TSearchParamsOperationDefinition[a] = a);
    indexes.add(frtOperationDefinition, CODES_TSearchParamsOperationDefinition[a], DESC_TSearchParamsOperationDefinition[a], TYPES_TSearchParamsOperationDefinition[a], TARGETS_TSearchParamsOperationDefinition[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesOperationDefinition(key : integer; id : String; context : TFhirResource; resource: TFhirOperationDefinition);
var
  i : integer;
begin
  index(frtOperationDefinition, key, 0, resource.identifierElement, 'identifier');
  index(frtOperationDefinition, key, 0, resource.statusElement, 'http://hl7.org/fhir/resource-profile-status', 'status');
  index(frtOperationDefinition, key, 0, resource.versionElement, 'version');
  index(frtOperationDefinition, key, 0, resource.publisherElement, 'publisher');
  index(frtOperationDefinition, key, 0, resource.nameElement, 'name');
  index(frtOperationDefinition, key, 0, resource.titleElement, 'title');
  for i := 0 to resource.CodeList.count - 1 Do
    index(frtOperationDefinition, key, 0, resource.CodeList[i], 'code');
  index(context, frtOperationDefinition, key, 0, resource.base, 'base');
  index(frtOperationDefinition, key, 0, resource.dateElement, 'date');
  index(frtOperationDefinition, key, 0, resource.kindElement, 'http://hl7.org/fhir/operation-kind', 'kind');
  index(frtOperationDefinition, key, 0, resource.system, 'system');
  for i := 0 to resource.type_List.count - 1 Do
    index(frtOperationDefinition, key, 0, resource.type_List[i], 'type');
  index(frtOperationDefinition, key, 0, resource.instance, 'instance');
  for i := 0 to resource.parameterList.count - 1 Do
    index(context, frtOperationDefinition, key, 0, resource.parameterList[i].profile, 'profile');
end;

const
  CHECK_TSearchParamsReferralRequest : Array[TSearchParamsReferralRequest] of TSearchParamsReferralRequest = ( spReferralRequest__id, spReferralRequest__language, spReferralRequest__lastUpdated, spReferralRequest__profile, spReferralRequest__security, spReferralRequest__tag,
     spReferralRequest_Patient, spReferralRequest_Priority, spReferralRequest_Recipient, spReferralRequest_Specialty, spReferralRequest_Status, spReferralRequest_Type);

procedure TFhirIndexManager.buildIndexesReferralRequest;
var
  a : TSearchParamsReferralRequest;
begin
  for a := low(TSearchParamsReferralRequest) to high(TSearchParamsReferralRequest) do
  begin
    assert(CHECK_TSearchParamsReferralRequest[a] = a);
    indexes.add(frtReferralRequest, CODES_TSearchParamsReferralRequest[a], DESC_TSearchParamsReferralRequest[a], TYPES_TSearchParamsReferralRequest[a], TARGETS_TSearchParamsReferralRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesReferralRequest(key : integer; id : String; context : TFhirResource; resource: TFhirReferralRequest);
var
  i : integer;
begin
  patientCompartment(key, resource.patient);
  index(context, frtReferralRequest, key, 0, resource.patient, 'patient');
  index(frtReferralRequest, key, 0, resource.statusElement, 'http://hl7.org/fhir/referralstatus', 'status');
  index(frtReferralRequest, key, 0, resource.priority, 'priority');
  for i := 0 to resource.recipientList.Count - 1 do
    index(context, frtReferralRequest, key, 0, resource.recipientList[i], 'recipient');
  index(frtReferralRequest, key, 0, resource.specialty, 'specialty');
  index(frtReferralRequest, key, 0, resource.type_, 'type');
end;

const
  CHECK_TSearchParamsNutritionOrder : Array[TSearchParamsNutritionOrder] of TSearchParamsNutritionOrder = ( spNutritionOrder__id, spNutritionOrder__language, spNutritionOrder__lastUpdated, spNutritionOrder__profile, spNutritionOrder__security, spNutritionOrder__tag,
     spNutritionOrder_Additive, spNutritionOrder_Datetime, spNutritionOrder_Encounter, spNutritionOrder_Formula, spNutritionOrder_Identifier, spNutritionOrder_Oraldiet, spNutritionOrder_Patient, spNutritionOrder_Provider, spNutritionOrder_Status, spNutritionOrder_Subject, spNutritionOrder_Supplement);

procedure TFhirIndexManager.buildIndexesNutritionOrder;
var
  a : TSearchParamsNutritionOrder;
begin
  for a := low(TSearchParamsNutritionOrder) to high(TSearchParamsNutritionOrder) do
  begin
    assert(CHECK_TSearchParamsNutritionOrder[a] = a);
    indexes.add(frtNutritionOrder, CODES_TSearchParamsNutritionOrder[a], DESC_TSearchParamsNutritionOrder[a], TYPES_TSearchParamsNutritionOrder[a], TARGETS_TSearchParamsNutritionOrder[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesNutritionOrder(key : integer; id : String; context : TFhirResource; resource: TFhirNutritionOrder);
var
  item : TFhirNutritionOrderItem;
begin
  patientCompartment(key, resource.subject);
  index(context, frtNutritionOrder, key, 0, resource.subject, 'subject');
  index(context, frtNutritionOrder, key, 0, resource.subject, 'patient');
  index(context, frtNutritionOrder, key, 0, resource.orderer, 'provider');
  index(frtNutritionOrder, key, 0, resource.statusElement, 'http://hl7.org/fhir/nutrition-order-status', 'status');
  index(context, frtNutritionOrder, key, 0, resource.encounter, 'encounter');
  index(frtNutritionOrder, key, 0, resource.identifierList, 'identifier');
  index(frtNutritionOrder, key, 0, resource.dateTimeElement, 'datetime');

  for item in resource.itemList do
  begin
    if item.oralDiet <> nil then
      index(frtNutritionOrder, key, 0, item.oralDiet.type_List, 'oraldiet');
    if item.supplement <> nil then
      index(frtNutritionOrder, key, 0, item.supplement.type_, 'supplement');
    if item.enteralFormula <> nil then
    begin
      index(frtNutritionOrder, key, 0, item.enteralFormula.additiveType, 'additive');
      index(frtNutritionOrder, key, 0, item.enteralFormula.baseFormulaType, 'formula');
    end;
  end;
end;

const
  CHECK_TSearchParamsCarePlan2 : Array[TSearchParamsCarePlan2] of TSearchParamsCarePlan2 = ( spCarePlan2__id, spCarePlan2__language, spCarePlan2__lastUpdated, spCarePlan2__profile, spCarePlan2__security, spCarePlan2__tag,
    spCarePlan2_Condition, spCarePlan2_Date, spCarePlan2_Participant, spCarePlan2_Patient);

procedure TFhirIndexManager.buildIndexesCarePlan2;
var
  a : TSearchParamsCarePlan2;
begin
  for a := low(TSearchParamsCarePlan2) to high(TSearchParamsCarePlan2) do
  begin
    assert(CHECK_TSearchParamsCarePlan2[a] = a);
    indexes.add(frtCarePlan2, CODES_TSearchParamsCarePlan2[a], DESC_TSearchParamsCarePlan2[a], TYPES_TSearchParamsCarePlan2[a], TARGETS_TSearchParamsCarePlan2[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCarePlan2(key: integer; id : String; context : TFhirResource; resource: TFhirCarePlan2);
var
  i : integer;
begin
  index(context, frtCarePlan2, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  for i := 0 to resource.concernList.Count - 1 do
    index(context, frtCarePlan2, key, 0, resource.concernList[i], 'condition');
  index(frtCarePlan2, key, 0, resource.period, 'date');
  for i := 0 to resource.participantList.Count - 1 do
    index(context, frtCarePlan2, key, 0, resource.participantList[i].member, 'participant');
end;

const
  CHECK_TSearchParamsClinicalAssessment : Array[TSearchParamsClinicalAssessment] of TSearchParamsClinicalAssessment = ( spClinicalAssessment__id, spClinicalAssessment__language, spClinicalAssessment__lastUpdated, spClinicalAssessment__profile, spClinicalAssessment__security, spClinicalAssessment__tag,
    spClinicalAssessment_Action, spClinicalAssessment_Assessor, spClinicalAssessment_Careplan, spClinicalAssessment_Date, spClinicalAssessment_Diagnosis, spClinicalAssessment_Investigation, spClinicalAssessment_Patient, spClinicalAssessment_Plan, spClinicalAssessment_Previous, spClinicalAssessment_Problem, spClinicalAssessment_Referral, spClinicalAssessment_Resolved, spClinicalAssessment_Ruledout);

procedure TFhirIndexManager.buildIndexesClinicalAssessment;
var
  a : TSearchParamsClinicalAssessment;
begin
  for a := low(TSearchParamsClinicalAssessment) to high(TSearchParamsClinicalAssessment) do
  begin
    assert(CHECK_TSearchParamsClinicalAssessment[a] = a);
    indexes.add(frtClinicalAssessment, CODES_TSearchParamsClinicalAssessment[a], DESC_TSearchParamsClinicalAssessment[a], TYPES_TSearchParamsClinicalAssessment[a], TARGETS_TSearchParamsClinicalAssessment[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesClinicalAssessment(key: integer; id : String; context : TFhirResource; resource: TFhirClinicalAssessment);
var
  i, j : integer;
begin
  index(context, frtClinicalAssessment, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(context, frtClinicalAssessment, key, 0, resource.plan, 'plan');
  index(context, frtClinicalAssessment, key, 0, resource.careplan, 'careplan');
  index(context, frtClinicalAssessment, key, 0, resource.previous, 'previous');
  index(frtClinicalAssessment, key, 0, resource.dateElement, 'date');
  for i := 0 to resource.problemList.Count - 1 do
    index(context, frtClinicalAssessment, key, 0, resource.problemList[i], 'problem');
  index(context, frtClinicalAssessment, key, 0, resource.referral, 'referral');
  for i := 0 to resource.investigationsList.Count - 1 do
    for j := 0 to resource.investigationsList[i].itemList.Count - 1 do
      index(context, frtClinicalAssessment, key, 0, resource.investigationsList[i].itemList[j], 'investigation');
  for i := 0 to resource.diagnosisList.Count - 1 do
    index(frtClinicalAssessment, key, 0, resource.diagnosisList[i].item, 'diagnosis');
  index(context, frtClinicalAssessment, key, 0, resource.assessor, 'assessor');
  for i := 0 to resource.actionList.Count - 1 do
    index(context, frtClinicalAssessment, key, 0, resource.actionList[i], 'action');
  index(frtClinicalAssessment, key, 0, resource.resolvedList, 'resolved');
  for i := 0 to resource.ruledOutList.Count - 1 do
    index(frtClinicalAssessment, key, 0, resource.ruledOutList[i].item, 'ruledout');
end;

const
  CHECK_TSearchParamsCommunication : Array[TSearchParamsCommunication] of TSearchParamsCommunication = ( spCommunication__id, spCommunication__language, spCommunication__lastUpdated, spCommunication__profile, spCommunication__security, spCommunication__tag,
    spCommunication_Category, spCommunication_Encounter, spCommunication_Identifier, spCommunication_Medium, spCommunication_Patient, spCommunication_Received, spCommunication_Recipient, spCommunication_Sender, spCommunication_Sent, spCommunication_Status, spCommunication_Subject);

procedure TFhirIndexManager.buildIndexesCommunication;
var
  a : TSearchParamsCommunication;
begin
  for a := low(TSearchParamsCommunication) to high(TSearchParamsCommunication) do
  begin
    assert(CHECK_TSearchParamsCommunication[a] = a);
    indexes.add(frtCommunication, CODES_TSearchParamsCommunication[a], DESC_TSearchParamsCommunication[a], TYPES_TSearchParamsCommunication[a], TARGETS_TSearchParamsCommunication[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCommunication(key: integer; id : String; context : TFhirResource; resource: TFhirCommunication);
var
  i, j : integer;
begin
  index(context, frtCommunication, key, 0, resource.subject, 'patient');
  index(context, frtCommunication, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  index(frtCommunication, key, 0, resource.category, 'category');
  index(context, frtCommunication, key, 0, resource.encounter, 'encounter');
  index(frtCommunication, key, 0, resource.identifierList, 'identifier');
  index(frtCommunication, key, 0, resource.mediumList, 'medium');
  index(frtCommunication, key, 0, resource.receivedElement, 'received');
  index(frtCommunication, key, 0, resource.sentElement, 'sent');
  for i := 0 to resource.recipientList.count - 1 do
    index(context, frtCommunication, key, 0, resource.recipientList[i], 'recipient');
  index(context, frtCommunication, key, 0, resource.sender, 'sender');
  index(frtCommunication, key, 0, resource.statusElement, 'http://hl7.org/fhir/communication-status', 'status');
end;

const
  CHECK_TSearchParamsCommunicationRequest : Array[TSearchParamsCommunicationRequest] of TSearchParamsCommunicationRequest = ( spCommunicationRequest__id, spCommunicationRequest__language, spCommunicationRequest__lastUpdated, spCommunicationRequest__profile, spCommunicationRequest__security, spCommunicationRequest__tag,
    spCommunicationRequest_Category, spCommunicationRequest_Encounter, spCommunicationRequest_Identifier, spCommunicationRequest_Medium, spCommunicationRequest_Ordered, spCommunicationRequest_Patient, spCommunicationRequest_Priority, spCommunicationRequest_Recipient, spCommunicationRequest_Requester, spCommunicationRequest_Sender, spCommunicationRequest_Status, spCommunicationRequest_Subject, spCommunicationRequest_Time);

procedure TFhirIndexManager.buildIndexesCommunicationRequest;
var
  a : TSearchParamsCommunicationRequest;
begin
  for a := low(TSearchParamsCommunicationRequest) to high(TSearchParamsCommunicationRequest) do
  begin
    assert(CHECK_TSearchParamsCommunicationRequest[a] = a);
    indexes.add(frtCommunicationRequest, CODES_TSearchParamsCommunicationRequest[a], DESC_TSearchParamsCommunicationRequest[a], TYPES_TSearchParamsCommunicationRequest[a], TARGETS_TSearchParamsCommunicationRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesCommunicationRequest(key: integer; id : String; context : TFhirResource; resource: TFhirCommunicationRequest);
var
  i, j : integer;
begin
  index(context, frtCommunicationRequest, key, 0, resource.subject, 'patient');
  index(context, frtCommunicationRequest, key, 0, resource.subject, 'subject');
  patientCompartment(key, resource.subject);
  index(frtCommunicationRequest, key, 0, resource.category, 'category');
  index(context, frtCommunicationRequest, key, 0, resource.encounter, 'encounter');
  index(frtCommunicationRequest, key, 0, resource.identifierList, 'identifier');
  index(frtCommunicationRequest, key, 0, resource.mediumList, 'medium');
  for i := 0 to resource.recipientList.count - 1 do
    index(context, frtCommunicationRequest, key, 0, resource.recipientList[i], 'recipient');
  index(context, frtCommunicationRequest, key, 0, resource.sender, 'sender');
  index(context, frtCommunicationRequest, key, 0, resource.requester, 'requester');
  index(frtCommunicationRequest, key, 0, resource.orderedOnElement, 'ordered');
  index(frtCommunicationRequest, key, 0, resource.scheduledTimeElement, 'time');
  index(frtCommunicationRequest, key, 0, resource.priority, 'priority');
  index(frtCommunicationRequest, key, 0, resource.statusElement, 'http://hl7.org/fhir/communication-request-status', 'status');
end;

const
  CHECK_TSearchParamsDeviceComponent : Array[TSearchParamsDeviceComponent] of TSearchParamsDeviceComponent = ( spDeviceComponent__id, spDeviceComponent__language, spDeviceComponent__lastUpdated, spDeviceComponent__profile, spDeviceComponent__security, spDeviceComponent__tag,
    spDeviceComponent_Parent, spDeviceComponent_Source, spDeviceComponent_Type);

procedure TFhirIndexManager.buildIndexesDeviceComponent;
var
  a : TSearchParamsDeviceComponent;
begin
  for a := low(TSearchParamsDeviceComponent) to high(TSearchParamsDeviceComponent) do
  begin
    assert(CHECK_TSearchParamsDeviceComponent[a] = a);
    indexes.add(frtDeviceComponent, CODES_TSearchParamsDeviceComponent[a], DESC_TSearchParamsDeviceComponent[a], TYPES_TSearchParamsDeviceComponent[a], TARGETS_TSearchParamsDeviceComponent[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDeviceComponent(key: integer; id : String; context : TFhirResource; resource: TFhirDeviceComponent);
var
  i, j : integer;
begin
  index(context, frtDeviceComponent, key, 0, resource.parent, 'parent');
  index(context, frtDeviceComponent, key, 0, resource.source, 'source');
  index(frtDeviceComponent, key, 0, resource.type_, 'type');
end;

const
  CHECK_TSearchParamsDeviceMetric : Array[TSearchParamsDeviceMetric] of TSearchParamsDeviceMetric = ( spDeviceMetric__id, spDeviceMetric__language, spDeviceMetric__lastUpdated, spDeviceMetric__profile, spDeviceMetric__security, spDeviceMetric__tag,
    spDeviceMetric_Category, spDeviceMetric_Identifier, spDeviceMetric_Parent, spDeviceMetric_Source, spDeviceMetric_Type);

procedure TFhirIndexManager.buildIndexesDeviceMetric;
var
  a : TSearchParamsDeviceMetric;
begin
  for a := low(TSearchParamsDeviceMetric) to high(TSearchParamsDeviceMetric) do
  begin
    assert(CHECK_TSearchParamsDeviceMetric[a] = a);
    indexes.add(frtDeviceMetric, CODES_TSearchParamsDeviceMetric[a], DESC_TSearchParamsDeviceMetric[a], TYPES_TSearchParamsDeviceMetric[a], TARGETS_TSearchParamsDeviceMetric[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDeviceMetric(key: integer; id : String; context : TFhirResource; resource: TFhirDeviceMetric);
var
  i, j : integer;
begin
  index(context, frtDeviceMetric, key, 0, resource.parent, 'parent');
  index(context, frtDeviceMetric, key, 0, resource.source, 'source');
  index(frtDeviceMetric, key, 0, resource.type_, 'type');
  index(frtDeviceMetric, key, 0, resource.identifierElement, 'identifier');
  index(frtDeviceMetric, key, 0, resource.categoryElement, 'http://hl7.org/fhir/metric-category', 'category');
end;

const
  CHECK_TSearchParamsDeviceUseRequest : Array[TSearchParamsDeviceUseRequest] of TSearchParamsDeviceUseRequest = ( spDeviceUseRequest__id, spDeviceUseRequest__language, spDeviceUseRequest__lastUpdated, spDeviceUseRequest__profile, spDeviceUseRequest__security, spDeviceUseRequest__tag,
    spDeviceUseRequest_Patient, spDeviceUseRequest_Subject);

procedure TFhirIndexManager.buildIndexesDeviceUseRequest;
var
  a : TSearchParamsDeviceUseRequest;
begin
  for a := low(TSearchParamsDeviceUseRequest) to high(TSearchParamsDeviceUseRequest) do
  begin
    assert(CHECK_TSearchParamsDeviceUseRequest[a] = a);
    indexes.add(frtDeviceUseRequest, CODES_TSearchParamsDeviceUseRequest[a], DESC_TSearchParamsDeviceUseRequest[a], TYPES_TSearchParamsDeviceUseRequest[a], TARGETS_TSearchParamsDeviceUseRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDeviceUseRequest(key: integer; id : String; context : TFhirResource; resource: TFhirDeviceUseRequest);
var
  i, j : integer;
begin
  index(context, frtDeviceUseRequest, key, 0, resource.subject, 'subject');
  index(context, frtDeviceUseRequest, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

const
  CHECK_TSearchParamsDeviceUseStatement : Array[TSearchParamsDeviceUseStatement] of TSearchParamsDeviceUseStatement = ( spDeviceUseStatement__id, spDeviceUseStatement__language, spDeviceUseStatement__lastUpdated, spDeviceUseStatement__profile, spDeviceUseStatement__security, spDeviceUseStatement__tag,
    spDeviceUseStatement_Patient, spDeviceUseStatement_Subject);

procedure TFhirIndexManager.buildIndexesDeviceUseStatement;
var
  a : TSearchParamsDeviceUseStatement;
begin
  for a := low(TSearchParamsDeviceUseStatement) to high(TSearchParamsDeviceUseStatement) do
  begin
    assert(CHECK_TSearchParamsDeviceUseStatement[a] = a);
    indexes.add(frtDeviceUseStatement, CODES_TSearchParamsDeviceUseStatement[a], DESC_TSearchParamsDeviceUseStatement[a], TYPES_TSearchParamsDeviceUseStatement[a], TARGETS_TSearchParamsDeviceUseStatement[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesDeviceUseStatement(key: integer; id : String; context : TFhirResource; resource: TFhirDeviceUseStatement);
var
  i, j : integer;
begin
  index(context, frtDeviceUseStatement, key, 0, resource.subject, 'subject');
  index(context, frtDeviceUseStatement, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

const
  CHECK_TSearchParamsEligibilityRequest : Array[TSearchParamsEligibilityRequest] of TSearchParamsEligibilityRequest = ( spEligibilityRequest__id, spEligibilityRequest__language, spEligibilityRequest__lastUpdated, spEligibilityRequest__profile, spEligibilityRequest__security, spEligibilityRequest__tag,
    spEligibilityRequest_Identifier);

procedure TFhirIndexManager.buildIndexesEligibilityRequest;
var
  a : TSearchParamsEligibilityRequest;
begin
  for a := low(TSearchParamsEligibilityRequest) to high(TSearchParamsEligibilityRequest) do
  begin
    assert(CHECK_TSearchParamsEligibilityRequest[a] = a);
    indexes.add(frtEligibilityRequest, CODES_TSearchParamsEligibilityRequest[a], DESC_TSearchParamsEligibilityRequest[a], TYPES_TSearchParamsEligibilityRequest[a], TARGETS_TSearchParamsEligibilityRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEligibilityRequest(key: integer; id : String; context : TFhirResource; resource: TFhirEligibilityRequest);
begin
  index(frtEligibilityRequest, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsEligibilityResponse : Array[TSearchParamsEligibilityResponse] of TSearchParamsEligibilityResponse = ( spEligibilityResponse__id, spEligibilityResponse__language, spEligibilityResponse__lastUpdated, spEligibilityResponse__profile, spEligibilityResponse__security, spEligibilityResponse__tag,
    spEligibilityResponse_Identifier);

procedure TFhirIndexManager.buildIndexesEligibilityResponse;
var
  a : TSearchParamsEligibilityResponse;
begin
  for a := low(TSearchParamsEligibilityResponse) to high(TSearchParamsEligibilityResponse) do
  begin
    assert(CHECK_TSearchParamsEligibilityResponse[a] = a);
    indexes.add(frtEligibilityResponse, CODES_TSearchParamsEligibilityResponse[a], DESC_TSearchParamsEligibilityResponse[a], TYPES_TSearchParamsEligibilityResponse[a], TARGETS_TSearchParamsEligibilityResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEligibilityResponse(key: integer; id : String; context : TFhirResource; resource: TFhirEligibilityResponse);
begin
  index(frtEligibilityResponse, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsEnrollmentRequest : Array[TSearchParamsEnrollmentRequest] of TSearchParamsEnrollmentRequest = ( spEnrollmentRequest__id, spEnrollmentRequest__language, spEnrollmentRequest__lastUpdated, spEnrollmentRequest__profile, spEnrollmentRequest__security, spEnrollmentRequest__tag,
    spEnrollmentRequest_Identifier, spEnrollmentRequest_Patient, spEnrollmentRequest_Subject);

procedure TFhirIndexManager.buildIndexesEnrollmentRequest;
var
  a : TSearchParamsEnrollmentRequest;
begin
  for a := low(TSearchParamsEnrollmentRequest) to high(TSearchParamsEnrollmentRequest) do
  begin
    assert(CHECK_TSearchParamsEnrollmentRequest[a] = a);
    indexes.add(frtEnrollmentRequest, CODES_TSearchParamsEnrollmentRequest[a], DESC_TSearchParamsEnrollmentRequest[a], TYPES_TSearchParamsEnrollmentRequest[a], TARGETS_TSearchParamsEnrollmentRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEnrollmentRequest(key: integer; id : String; context : TFhirResource; resource: TFhirEnrollmentRequest);
begin
  index(frtEnrollmentRequest, key, 0, resource.identifierList, 'identifier');
  index(context, frtEnrollmentRequest, key, 0, resource.subject, 'subject');
  index(context, frtEnrollmentRequest, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

const
  CHECK_TSearchParamsEnrollmentResponse : Array[TSearchParamsEnrollmentResponse] of TSearchParamsEnrollmentResponse = ( spEnrollmentResponse__id, spEnrollmentResponse__language, spEnrollmentResponse__lastUpdated, spEnrollmentResponse__profile, spEnrollmentResponse__security, spEnrollmentResponse__tag,
    spEnrollmentResponse_Identifier);

procedure TFhirIndexManager.buildIndexesEnrollmentResponse;
var
  a : TSearchParamsEnrollmentResponse;
begin
  for a := low(TSearchParamsEnrollmentResponse) to high(TSearchParamsEnrollmentResponse) do
  begin
    assert(CHECK_TSearchParamsEnrollmentResponse[a] = a);
    indexes.add(frtEnrollmentResponse, CODES_TSearchParamsEnrollmentResponse[a], DESC_TSearchParamsEnrollmentResponse[a], TYPES_TSearchParamsEnrollmentResponse[a], TARGETS_TSearchParamsEnrollmentResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEnrollmentResponse(key: integer; id : String; context : TFhirResource; resource: TFhirEnrollmentResponse);
begin
  index(frtEnrollmentResponse, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsEpisodeOfCare : Array[TSearchParamsEpisodeOfCare] of TSearchParamsEpisodeOfCare = ( spEpisodeOfCare__id, spEpisodeOfCare__language, spEpisodeOfCare__lastUpdated, spEpisodeOfCare__profile, spEpisodeOfCare__security, spEpisodeOfCare__tag,
    spEpisodeOfCare_Care_manager, spEpisodeOfCare_Condition, spEpisodeOfCare_Date, spEpisodeOfCare_Identifier, spEpisodeOfCare_Organization, spEpisodeOfCare_Patient, spEpisodeOfCare_Referral, spEpisodeOfCare_Status, spEpisodeOfCare_Type);

procedure TFhirIndexManager.buildIndexesEpisodeOfCare;
var
  a : TSearchParamsEpisodeOfCare;
begin
  for a := low(TSearchParamsEpisodeOfCare) to high(TSearchParamsEpisodeOfCare) do
  begin
    assert(CHECK_TSearchParamsEpisodeOfCare[a] = a);
    indexes.add(frtEpisodeOfCare, CODES_TSearchParamsEpisodeOfCare[a], DESC_TSearchParamsEpisodeOfCare[a], TYPES_TSearchParamsEpisodeOfCare[a], TARGETS_TSearchParamsEpisodeOfCare[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesEpisodeOfCare(key: integer; id : String; context : TFhirResource; resource: TFhirEpisodeOfCare);
var
  i : integer;
begin
  index(frtEpisodeOfCare, key, 0, resource.identifierList, 'identifier');
  index(context, frtEpisodeOfCare, key, 0, resource.managingOrganization, 'organization');
  index(context, frtEpisodeOfCare, key, 0, resource.patient, 'patient');
  index(context, frtEpisodeOfCare, key, 0, resource.referralRequest, 'referral');
  index(context, frtEpisodeOfCare, key, 0, resource.careManager, 'care-manager');
  patientCompartment(key, resource.patient);
  index(frtEpisodeOfCare, key, 0, resource.period, 'date');
  index(frtEpisodeOfCare, key, 0, resource.type_List, 'type');
  index(frtEpisodeOfCare, key, 0, resource.currentStatusElement, 'http://hl7.org/fhir/episode-of-care-status', 'status');
  for i := 0 to resource.conditionList.Count - 1 do
    index(context, frtEpisodeOfCare, key, 0, resource.conditionList[i], 'condition');
end;

const
  CHECK_TSearchParamsExplanationOfBenefit : Array[TSearchParamsExplanationOfBenefit] of TSearchParamsExplanationOfBenefit = ( spExplanationOfBenefit__id, spExplanationOfBenefit__language, spExplanationOfBenefit__lastUpdated, spExplanationOfBenefit__profile, spExplanationOfBenefit__security, spExplanationOfBenefit__tag,
    spExplanationOfBenefit_Identifier);

procedure TFhirIndexManager.buildIndexesExplanationOfBenefit;
var
  a : TSearchParamsExplanationOfBenefit;
begin
  for a := low(TSearchParamsExplanationOfBenefit) to high(TSearchParamsExplanationOfBenefit) do
  begin
    assert(CHECK_TSearchParamsExplanationOfBenefit[a] = a);
    indexes.add(frtExplanationOfBenefit, CODES_TSearchParamsExplanationOfBenefit[a], DESC_TSearchParamsExplanationOfBenefit[a], TYPES_TSearchParamsExplanationOfBenefit[a], TARGETS_TSearchParamsExplanationOfBenefit[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesExplanationOfBenefit(key: integer; id : String; context : TFhirResource; resource: TFhirExplanationOfBenefit);
var
  i : integer;
begin
  index(frtExplanationOfBenefit, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsExtensionDefinition : Array[TSearchParamsExtensionDefinition] of TSearchParamsExtensionDefinition = ( spExtensionDefinition__id, spExtensionDefinition__language, spExtensionDefinition__lastUpdated, spExtensionDefinition__profile, spExtensionDefinition__security, spExtensionDefinition__tag,
    spExtensionDefinition_Code, spExtensionDefinition_Date, spExtensionDefinition_Description, spExtensionDefinition_Identifier, spExtensionDefinition_Name, spExtensionDefinition_Publisher, spExtensionDefinition_Status, spExtensionDefinition_Url, spExtensionDefinition_Valueset);

procedure TFhirIndexManager.buildIndexesExtensionDefinition;
var
  a : TSearchParamsExtensionDefinition;
begin
  for a := low(TSearchParamsExtensionDefinition) to high(TSearchParamsExtensionDefinition) do
  begin
    assert(CHECK_TSearchParamsExtensionDefinition[a] = a);
    indexes.add(frtExtensionDefinition, CODES_TSearchParamsExtensionDefinition[a], DESC_TSearchParamsExtensionDefinition[a], TYPES_TSearchParamsExtensionDefinition[a], TARGETS_TSearchParamsExtensionDefinition[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesExtensionDefinition(key: integer; id : String; context : TFhirResource; resource: TFhirExtensionDefinition);
var
  i, j : integer;
  procedure indexElement(element : TFhirElementDefinition);
  begin
    {$IFDEF FHIR-DSTU}
    if (element.definition <> nil) and
      (element.definition.binding <> nil) then
      if element.definition.binding.reference is TFhirUri then
        index(frtProfile, key, 0, TFhirUri(element.definition.binding.reference), 'valueset')
      else
        index(context, frtProfile, key, 0, TFhirReference(element.definition.binding.reference), 'valueset');
    {$ELSE}
    if (element.binding <> nil) then
      if element.binding.reference is TFhirUri then
        index(frtProfile, key, 0, TFhirUri(element.binding.reference), 'valueset')
      else
        index(context, frtProfile, key, 0, TFhirReference(element.binding.reference), 'valueset');
    {$ENDIF}
  end;
begin
  index(frtExtensionDefinition, key, 0, resource.identifierList, 'identifier');
  index(frtExtensionDefinition, key, 0, resource.codeList, 'code');
  index(frtExtensionDefinition, key, 0, resource.dateElement, 'date');
  index(frtExtensionDefinition, key, 0, resource.descriptionElement, 'description');
  index(frtExtensionDefinition, key, 0, resource.nameElement, 'name');
  index(frtExtensionDefinition, key, 0, resource.publisher, 'publisher');
  index(frtExtensionDefinition, key, 0, resource.url, 'url');
  index(frtExtensionDefinition, key, 0, resource.statusElement, 'http://hl7.org/fhir/resource-profile-status', 'status');
  for j := 0 to resource.elementList.Count - 1 do
    indexElement(resource.elementList[j]);
end;

const
  CHECK_TSearchParamsGoal : Array[TSearchParamsGoal] of TSearchParamsGoal = ( spGoal__id, spGoal__language, spGoal__lastUpdated, spGoal__profile, spGoal__security, spGoal__tag,
    spGoal_Patient);

procedure TFhirIndexManager.buildIndexesGoal;
var
  a : TSearchParamsGoal;
begin
  for a := low(TSearchParamsGoal) to high(TSearchParamsGoal) do
  begin
    assert(CHECK_TSearchParamsGoal[a] = a);
    indexes.add(frtGoal, CODES_TSearchParamsGoal[a], DESC_TSearchParamsGoal[a], TYPES_TSearchParamsGoal[a], TARGETS_TSearchParamsGoal[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesGoal(key: integer; id : String; context : TFhirResource; resource: TFhirGoal);
begin
  index(context, frtGoal, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
end;

const
  CHECK_TSearchParamsImagingObjectSelection : Array[TSearchParamsImagingObjectSelection] of TSearchParamsImagingObjectSelection = ( spImagingObjectSelection__id, spImagingObjectSelection__language, spImagingObjectSelection__lastUpdated, spImagingObjectSelection__profile, spImagingObjectSelection__security, spImagingObjectSelection__tag,
    spImagingObjectSelection_Author, spImagingObjectSelection_Authoring_time, spImagingObjectSelection_Identifier, spImagingObjectSelection_Patient, spImagingObjectSelection_Selected_study, spImagingObjectSelection_Title);

procedure TFhirIndexManager.buildIndexesImagingObjectSelection;
var
  a : TSearchParamsImagingObjectSelection;
begin
  for a := low(TSearchParamsImagingObjectSelection) to high(TSearchParamsImagingObjectSelection) do
  begin
    assert(CHECK_TSearchParamsImagingObjectSelection[a] = a);
    indexes.add(frtImagingObjectSelection, CODES_TSearchParamsImagingObjectSelection[a], DESC_TSearchParamsImagingObjectSelection[a], TYPES_TSearchParamsImagingObjectSelection[a], TARGETS_TSearchParamsImagingObjectSelection[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesImagingObjectSelection(key: integer; id : String; context : TFhirResource; resource: TFhirImagingObjectSelection);
var
  i : integer;
begin
  index(context, frtImagingObjectSelection, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(context, frtImagingObjectSelection, key, 0, resource.author, 'author');
  index(frtImagingObjectSelection, key, 0, resource.authoringTimeElement, 'authoring-time');
  index(frtImagingObjectSelection, key, 0, resource.uidElement, 'identifier');
  index(frtImagingObjectSelection, key, 0, resource.title, 'title');
  for i := 0 to resource.studyList.Count - 1 do
    index(frtImagingObjectSelection, key, 0, resource.studyList[i].uid, 'selected-study');
end;

const
  CHECK_TSearchParamsInstitutionalClaim : Array[TSearchParamsInstitutionalClaim] of TSearchParamsInstitutionalClaim = ( spInstitutionalClaim__id, spInstitutionalClaim__language, spInstitutionalClaim__lastUpdated, spInstitutionalClaim__profile, spInstitutionalClaim__security, spInstitutionalClaim__tag,
    spInstitutionalClaim_Identifier, spInstitutionalClaim_Patient, spInstitutionalClaim_Priority, spInstitutionalClaim_Use);

procedure TFhirIndexManager.buildIndexesInstitutionalClaim;
var
  a : TSearchParamsInstitutionalClaim;
begin
  for a := low(TSearchParamsInstitutionalClaim) to high(TSearchParamsInstitutionalClaim) do
  begin
    assert(CHECK_TSearchParamsInstitutionalClaim[a] = a);
    indexes.add(frtInstitutionalClaim, CODES_TSearchParamsInstitutionalClaim[a], DESC_TSearchParamsInstitutionalClaim[a], TYPES_TSearchParamsInstitutionalClaim[a], TARGETS_TSearchParamsInstitutionalClaim[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesInstitutionalClaim(key: integer; id : String; context : TFhirResource; resource: TFhirInstitutionalClaim);
var
  i : integer;
begin
  index(context, frtInstitutionalClaim, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(frtInstitutionalClaim, key, 0, resource.identifierList, 'identifier');
  index(frtInstitutionalClaim, key, 0, resource.priority, 'priority');
  index(frtInstitutionalClaim, key, 0, resource.useElement, 'http://hl7.org/fhir/use-link', 'use');
end;

const
  CHECK_TSearchParamsPaymentNotice : Array[TSearchParamsPaymentNotice] of TSearchParamsPaymentNotice = ( spPaymentNotice__id, spPaymentNotice__language, spPaymentNotice__lastUpdated, spPaymentNotice__profile, spPaymentNotice__security, spPaymentNotice__tag,
    spPaymentNotice_Identifier);

procedure TFhirIndexManager.buildIndexesPaymentNotice;
var
  a : TSearchParamsPaymentNotice;
begin
  for a := low(TSearchParamsPaymentNotice) to high(TSearchParamsPaymentNotice) do
  begin
    assert(CHECK_TSearchParamsPaymentNotice[a] = a);
    indexes.add(frtPaymentNotice, CODES_TSearchParamsPaymentNotice[a], DESC_TSearchParamsPaymentNotice[a], TYPES_TSearchParamsPaymentNotice[a], TARGETS_TSearchParamsPaymentNotice[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPaymentNotice(key: integer; id : String; context : TFhirResource; resource: TFhirPaymentNotice);
var
  i : integer;
begin
  index(frtPaymentNotice, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsPaymentReconciliation : Array[TSearchParamsPaymentReconciliation] of TSearchParamsPaymentReconciliation = ( spPaymentReconciliation__id, spPaymentReconciliation__language, spPaymentReconciliation__lastUpdated, spPaymentReconciliation__profile, spPaymentReconciliation__security, spPaymentReconciliation__tag,
    spPaymentReconciliation_Identifier);

procedure TFhirIndexManager.buildIndexesPaymentReconciliation;
var
  a : TSearchParamsPaymentReconciliation;
begin
  for a := low(TSearchParamsPaymentReconciliation) to high(TSearchParamsPaymentReconciliation) do
  begin
    assert(CHECK_TSearchParamsPaymentReconciliation[a] = a);
    indexes.add(frtPaymentReconciliation, CODES_TSearchParamsPaymentReconciliation[a], DESC_TSearchParamsPaymentReconciliation[a], TYPES_TSearchParamsPaymentReconciliation[a], TARGETS_TSearchParamsPaymentReconciliation[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPaymentReconciliation(key: integer; id : String; context : TFhirResource; resource: TFhirPaymentReconciliation);
var
  i : integer;
begin
  index(frtPaymentReconciliation, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsPendedRequest : Array[TSearchParamsPendedRequest] of TSearchParamsPendedRequest = ( spPendedRequest__id, spPendedRequest__language, spPendedRequest__lastUpdated, spPendedRequest__profile, spPendedRequest__security, spPendedRequest__tag,
    spPendedRequest_Identifier);

procedure TFhirIndexManager.buildIndexesPendedRequest;
var
  a : TSearchParamsPendedRequest;
begin
  for a := low(TSearchParamsPendedRequest) to high(TSearchParamsPendedRequest) do
  begin
    assert(CHECK_TSearchParamsPendedRequest[a] = a);
    indexes.add(frtPendedRequest, CODES_TSearchParamsPendedRequest[a], DESC_TSearchParamsPendedRequest[a], TYPES_TSearchParamsPendedRequest[a], TARGETS_TSearchParamsPendedRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPendedRequest(key: integer; id : String; context : TFhirResource; resource: TFhirPendedRequest);
var
  i : integer;
begin
  index(frtPendedRequest, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsPerson : Array[TSearchParamsPerson] of TSearchParamsPerson = ( spPerson__id, spPerson__language, spPerson__lastUpdated, spPerson__profile, spPerson__security, spPerson__tag,
    spPerson_Address, spPerson_Birthdate, spPerson_Gender, spPerson_Identifier, spPerson_Name, spPerson_Organization, spPerson_Phonetic, spPerson_Telecom);

procedure TFhirIndexManager.buildIndexesPerson;
var
  a : TSearchParamsPerson;
begin
  for a := low(TSearchParamsPerson) to high(TSearchParamsPerson) do
  begin
    assert(CHECK_TSearchParamsPerson[a] = a);
    indexes.add(frtPerson, CODES_TSearchParamsPerson[a], DESC_TSearchParamsPerson[a], TYPES_TSearchParamsPerson[a], TARGETS_TSearchParamsPerson[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPerson(key: integer; id : String; context : TFhirResource; resource: TFhirPerson);
var
  i, j : integer;
begin
  for i := 0 to resource.addressList.Count - 1 do
    index(frtPerson, key, 0, resource.addressList[i], 'address');
  index(frtPerson, key, 0, resource.identifierList, 'identifier');
  index(frtPerson, key, 0, resource.birthDateElement, 'birthdate');
  index(frtPerson, key, 0, resource.genderElement, 'http://hl7.org/fhir/administrative-gender', 'gender');
  for i := 0 to resource.nameList.count - 1 do
  begin
    index(frtPerson, key, 0, resource.nameList[i], 'name', 'phonetic');
//    for j := 0 to resource.nameList[i].givenList.count - 1 do
//      index(frtPerson, key, 0, resource.nameList[i].givenList[j], 'given');
//    for j := 0 to resource.nameList[i].familyList.count - 1 do
//      index(frtPerson, key, 0, resource.nameList[i].familyList[j], 'family');
  end;
  index(context, frtPerson, key, 0, resource.managingOrganization, 'organization');
  for i := 0 to resource.telecomList.Count - 1 do
    index(frtPerson, key, 0, resource.telecomList[i].valueElement, 'telecom');
end;

const
  CHECK_TSearchParamsPharmacyClaim : Array[TSearchParamsPharmacyClaim] of TSearchParamsPharmacyClaim = ( spPharmacyClaim__id, spPharmacyClaim__language, spPharmacyClaim__lastUpdated, spPharmacyClaim__profile, spPharmacyClaim__security, spPharmacyClaim__tag,
    spPharmacyClaim_Identifier, spPharmacyClaim_Patient, spPharmacyClaim_Priority, spPharmacyClaim_Use);

procedure TFhirIndexManager.buildIndexesPharmacyClaim;
var
  a : TSearchParamsPharmacyClaim;
begin
  for a := low(TSearchParamsPharmacyClaim) to high(TSearchParamsPharmacyClaim) do
  begin
    assert(CHECK_TSearchParamsPharmacyClaim[a] = a);
    indexes.add(frtPharmacyClaim, CODES_TSearchParamsPharmacyClaim[a], DESC_TSearchParamsPharmacyClaim[a], TYPES_TSearchParamsPharmacyClaim[a], TARGETS_TSearchParamsPharmacyClaim[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesPharmacyClaim(key: integer; id : String; context : TFhirResource; resource: TFhirPharmacyClaim);
var
  i : integer;
begin
  index(frtPharmacyClaim, key, 0, resource.identifierList, 'identifier');
  index(context, frtPharmacyClaim, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(frtPharmacyClaim, key, 0, resource.priority, 'priority');
  index(frtPharmacyClaim, key, 0, resource.useElement, 'http://hl7.org/fhir/use-link', 'use');
end;

const
  CHECK_TSearchParamsProcedureRequest : Array[TSearchParamsProcedureRequest] of TSearchParamsProcedureRequest = ( spProcedureRequest__id, spProcedureRequest__language, spProcedureRequest__lastUpdated, spProcedureRequest__profile, spProcedureRequest__security, spProcedureRequest__tag,
    spProcedureRequest_Patient, spProcedureRequest_Subject);

procedure TFhirIndexManager.buildIndexesProcedureRequest;
var
  a : TSearchParamsProcedureRequest;
begin
  for a := low(TSearchParamsProcedureRequest) to high(TSearchParamsProcedureRequest) do
  begin
    assert(CHECK_TSearchParamsProcedureRequest[a] = a);
    indexes.add(frtProcedureRequest, CODES_TSearchParamsProcedureRequest[a], DESC_TSearchParamsProcedureRequest[a], TYPES_TSearchParamsProcedureRequest[a], TARGETS_TSearchParamsProcedureRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesProcedureRequest(key: integer; id : String; context : TFhirResource; resource: TFhirProcedureRequest);
var
  i : integer;
begin
  index(context, frtProcedureRequest, key, 0, resource.subject, 'subject');
  index(context, frtProcedureRequest, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
end;

const
  CHECK_TSearchParamsProfessionalClaim : Array[TSearchParamsProfessionalClaim] of TSearchParamsProfessionalClaim = ( spProfessionalClaim__id, spProfessionalClaim__language, spProfessionalClaim__lastUpdated, spProfessionalClaim__profile, spProfessionalClaim__security, spProfessionalClaim__tag,
    spProfessionalClaim_Identifier, spProfessionalClaim_Patient, spProfessionalClaim_Priority, spProfessionalClaim_Use);

procedure TFhirIndexManager.buildIndexesProfessionalClaim;
var
  a : TSearchParamsProfessionalClaim;
begin
  for a := low(TSearchParamsProfessionalClaim) to high(TSearchParamsProfessionalClaim) do
  begin
    assert(CHECK_TSearchParamsProfessionalClaim[a] = a);
    indexes.add(frtProfessionalClaim, CODES_TSearchParamsProfessionalClaim[a], DESC_TSearchParamsProfessionalClaim[a], TYPES_TSearchParamsProfessionalClaim[a], TARGETS_TSearchParamsProfessionalClaim[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesProfessionalClaim(key: integer; id : String; context : TFhirResource; resource: TFhirProfessionalClaim);
var
  i : integer;
begin
  index(frtProfessionalClaim, key, 0, resource.identifierList, 'identifier');
  index(context, frtProfessionalClaim, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(frtProfessionalClaim, key, 0, resource.priority, 'priority');
  index(frtProfessionalClaim, key, 0, resource.useElement, 'http://hl7.org/fhir/use-link', 'use');
end;

const
  CHECK_TSearchParamsReadjudicate : Array[TSearchParamsReadjudicate] of TSearchParamsReadjudicate = ( spReadjudicate__id, spReadjudicate__language, spReadjudicate__lastUpdated, spReadjudicate__profile, spReadjudicate__security, spReadjudicate__tag,
    spReadjudicate_Identifier);

procedure TFhirIndexManager.buildIndexesReadjudicate;
var
  a : TSearchParamsReadjudicate;
begin
  for a := low(TSearchParamsReadjudicate) to high(TSearchParamsReadjudicate) do
  begin
    assert(CHECK_TSearchParamsReadjudicate[a] = a);
    indexes.add(frtReadjudicate, CODES_TSearchParamsReadjudicate[a], DESC_TSearchParamsReadjudicate[a], TYPES_TSearchParamsReadjudicate[a], TARGETS_TSearchParamsReadjudicate[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesReadjudicate(key: integer; id : String; context : TFhirResource; resource: TFhirReadjudicate);
var
  i : integer;
begin
  index(frtReadjudicate, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsReversal : Array[TSearchParamsReversal] of TSearchParamsReversal = ( spReversal__id, spReversal__language, spReversal__lastUpdated, spReversal__profile, spReversal__security, spReversal__tag,
    spReversal_Identifier);

procedure TFhirIndexManager.buildIndexesReversal;
var
  a : TSearchParamsReversal;
begin
  for a := low(TSearchParamsReversal) to high(TSearchParamsReversal) do
  begin
    assert(CHECK_TSearchParamsReversal[a] = a);
    indexes.add(frtReversal, CODES_TSearchParamsReversal[a], DESC_TSearchParamsReversal[a], TYPES_TSearchParamsReversal[a], TARGETS_TSearchParamsReversal[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesReversal(key: integer; id : String; context : TFhirResource; resource: TFhirReversal);
var
  i : integer;
begin
  index(frtReversal, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsSearchParameter : Array[TSearchParamsSearchParameter] of TSearchParamsSearchParameter = ( spSearchParameter__id, spSearchParameter__language, spSearchParameter__lastUpdated, spSearchParameter__profile, spSearchParameter__security, spSearchParameter__tag,
    spSearchParameter_Base, spSearchParameter_Description, spSearchParameter_Name, spSearchParameter_Target, spSearchParameter_Type, spSearchParameter_Url);

procedure TFhirIndexManager.buildIndexesSearchParameter;
var
  a : TSearchParamsSearchParameter;
begin
  for a := low(TSearchParamsSearchParameter) to high(TSearchParamsSearchParameter) do
  begin
    assert(CHECK_TSearchParamsSearchParameter[a] = a);
    indexes.add(frtSearchParameter, CODES_TSearchParamsSearchParameter[a], DESC_TSearchParamsSearchParameter[a], TYPES_TSearchParamsSearchParameter[a], TARGETS_TSearchParamsSearchParameter[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSearchParameter(key: integer; id : String; context : TFhirResource; resource: TFhirSearchParameter);
var
  i : integer;
begin
  index(frtSearchParameter, key, 0, resource.base, 'base');
  index(frtSearchParameter, key, 0, resource.description, 'description');
  index(frtSearchParameter, key, 0, resource.name, 'name');
  for i := 0 to resource.targetList.count - 1  do
    index(frtSearchParameter, key, 0, resource.targetList[i], 'name');
  index(frtSearchParameter, key, 0, resource.type_Element, 'http://hl7.org/fhir/search-param-type', 'type');
  index(frtSearchParameter, key, 0, resource.url, 'url');
end;

const
  CHECK_TSearchParamsStatusRequest : Array[TSearchParamsStatusRequest] of TSearchParamsStatusRequest = ( spStatusRequest__id, spStatusRequest__language, spStatusRequest__lastUpdated, spStatusRequest__profile, spStatusRequest__security, spStatusRequest__tag,
    spStatusRequest_Identifier);

procedure TFhirIndexManager.buildIndexesStatusRequest;
var
  a : TSearchParamsStatusRequest;
begin
  for a := low(TSearchParamsStatusRequest) to high(TSearchParamsStatusRequest) do
  begin
    assert(CHECK_TSearchParamsStatusRequest[a] = a);
    indexes.add(frtStatusRequest, CODES_TSearchParamsStatusRequest[a], DESC_TSearchParamsStatusRequest[a], TYPES_TSearchParamsStatusRequest[a], TARGETS_TSearchParamsStatusRequest[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesStatusRequest(key: integer; id : String; context : TFhirResource; resource: TFhirStatusRequest);
var
  i : integer;
begin
  index(frtStatusRequest, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsStatusResponse : Array[TSearchParamsStatusResponse] of TSearchParamsStatusResponse = ( spStatusResponse__id, spStatusResponse__language, spStatusResponse__lastUpdated, spStatusResponse__profile, spStatusResponse__security, spStatusResponse__tag,
    spStatusResponse_Identifier);

procedure TFhirIndexManager.buildIndexesStatusResponse;
var
  a : TSearchParamsStatusResponse;
begin
  for a := low(TSearchParamsStatusResponse) to high(TSearchParamsStatusResponse) do
  begin
    assert(CHECK_TSearchParamsStatusResponse[a] = a);
    indexes.add(frtStatusResponse, CODES_TSearchParamsStatusResponse[a], DESC_TSearchParamsStatusResponse[a], TYPES_TSearchParamsStatusResponse[a], TARGETS_TSearchParamsStatusResponse[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesStatusResponse(key: integer; id : String; context : TFhirResource; resource: TFhirStatusResponse);
var
  i : integer;
begin
  index(frtStatusResponse, key, 0, resource.identifierList, 'identifier');
end;

const
  CHECK_TSearchParamsSupportingDocumentation : Array[TSearchParamsSupportingDocumentation] of TSearchParamsSupportingDocumentation = ( spSupportingDocumentation__id, spSupportingDocumentation__language, spSupportingDocumentation__lastUpdated, spSupportingDocumentation__profile, spSupportingDocumentation__security, spSupportingDocumentation__tag,
    spSupportingDocumentation_Author, spSupportingDocumentation_Identifier, spSupportingDocumentation_Patient, spSupportingDocumentation_Subject);

procedure TFhirIndexManager.buildIndexesSupportingDocumentation;
var
  a : TSearchParamsSupportingDocumentation;
begin
  for a := low(TSearchParamsSupportingDocumentation) to high(TSearchParamsSupportingDocumentation) do
  begin
    assert(CHECK_TSearchParamsSupportingDocumentation[a] = a);
    indexes.add(frtSupportingDocumentation, CODES_TSearchParamsSupportingDocumentation[a], DESC_TSearchParamsSupportingDocumentation[a], TYPES_TSearchParamsSupportingDocumentation[a], TARGETS_TSearchParamsSupportingDocumentation[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesSupportingDocumentation(key: integer; id : String; context : TFhirResource; resource: TFhirSupportingDocumentation);
var
  i : integer;
begin
  index(frtSupportingDocumentation, key, 0, resource.identifierList, 'identifier');
  index(context, frtSupportingDocumentation, key, 0, resource.subject, 'subject');
  index(context, frtSupportingDocumentation, key, 0, resource.subject, 'patient');
  patientCompartment(key, resource.subject);
  index(context, frtSupportingDocumentation, key, 0, resource.author, 'author');
end;

const
  CHECK_TSearchParamsVisionClaim : Array[TSearchParamsVisionClaim] of TSearchParamsVisionClaim = ( spVisionClaim__id, spVisionClaim__language, spVisionClaim__lastUpdated, spVisionClaim__profile, spVisionClaim__security, spVisionClaim__tag,
    spVisionClaim_Identifier, spVisionClaim_Patient, spVisionClaim_Priority, spVisionClaim_Use);

procedure TFhirIndexManager.buildIndexesVisionClaim;
var
  a : TSearchParamsVisionClaim;
begin
  for a := low(TSearchParamsVisionClaim) to high(TSearchParamsVisionClaim) do
  begin
    assert(CHECK_TSearchParamsVisionClaim[a] = a);
    indexes.add(frtVisionClaim, CODES_TSearchParamsVisionClaim[a], DESC_TSearchParamsVisionClaim[a], TYPES_TSearchParamsVisionClaim[a], TARGETS_TSearchParamsVisionClaim[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesVisionClaim(key: integer; id : String; context : TFhirResource; resource: TFhirVisionClaim);
var
  i : integer;
begin
  index(frtVisionClaim, key, 0, resource.identifierList, 'identifier');
  index(context, frtVisionClaim, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(frtVisionClaim, key, 0, resource.priority, 'priority');
  index(frtVisionClaim, key, 0, resource.useElement, 'http://hl7.org/fhir/use-link', 'use');
end;

const
  CHECK_TSearchParamsVisionPrescription : Array[TSearchParamsVisionPrescription] of TSearchParamsVisionPrescription = ( spVisionPrescription__id, spVisionPrescription__language, spVisionPrescription__lastUpdated, spVisionPrescription__profile, spVisionPrescription__security, spVisionPrescription__tag,
    spVisionPrescription_Datewritten, spVisionPrescription_Encounter, spVisionPrescription_Identifier, spVisionPrescription_Patient);

procedure TFhirIndexManager.buildIndexesVisionPrescription;
var
  a : TSearchParamsVisionPrescription;
begin
  for a := low(TSearchParamsVisionPrescription) to high(TSearchParamsVisionPrescription) do
  begin
    assert(CHECK_TSearchParamsVisionPrescription[a] = a);
    indexes.add(frtVisionPrescription, CODES_TSearchParamsVisionPrescription[a], DESC_TSearchParamsVisionPrescription[a], TYPES_TSearchParamsVisionPrescription[a], TARGETS_TSearchParamsVisionPrescription[a]);
  end;
end;

procedure TFhirIndexManager.buildIndexValuesVisionPrescription(key: integer; id : String; context : TFhirResource; resource: TFhirVisionPrescription);
var
  i : integer;
begin
  index(frtVisionPrescription, key, 0, resource.identifierList, 'identifier');
  index(context, frtVisionPrescription, key, 0, resource.patient, 'patient');
  patientCompartment(key, resource.patient);
  index(frtVisionPrescription, key, 0, resource.dateWrittenElement, 'dateWritten');
  index(context, frtVisionPrescription, key, 0, resource.encounter, 'encounter');
end;

{$ENDIF}


{ TFhirCompartmentEntryList }

procedure TFhirCompartmentEntryList.add(key, ckey: integer; id: string);
var
  item : TFhirCompartmentEntry;
begin
  item := TFhirCompartmentEntry.create;
  try
    item.key := key;
    item.ckey := key;
    item.id := id;
    inherited add(item.Link);
  finally
    item.free;
  end;
end;

function TFhirCompartmentEntryList.GetItemN(iIndex: integer): TFhirCompartmentEntry;
begin
  result := TFhirCompartmentEntry(ObjectByIndex[iIndex]);
end;

function TFhirCompartmentEntryList.ItemClass: TAdvObjectClass;
begin
  result := TFhirCompartmentEntry;
end;

procedure TFhirCompartmentEntryList.removeById(id: String);
var
  i : integer;
begin
  for i := count - 1 downto 0 do
    if GetItemN(i).Id = id then
      DeleteByIndex(i);
end;

{ TFhirComposite }

procedure TFhirComposite.Assign(source: TAdvObject);
var
  s : String;
begin
  inherited;
  FResourceType := TFhirComposite(source).FResourceType;
  FKey := TFhirComposite(source).FKey;
  FName := TFhirComposite(source).FName;
  for s in TFhirComposite(source).FComponents.Keys do
    FComponents.Add(s, TFhirComposite(source).FComponents[s]);
end;

function TFhirComposite.Clone: TFhirComposite;
begin
  result := TFhirComposite(inherited Clone);
end;

constructor TFhirComposite.Create;
begin
  inherited;
  FComponents := TDictionary<String,String>.create;
end;

destructor TFhirComposite.Destroy;
begin
  FComponents.Free;
  inherited;
end;

function TFhirComposite.Link: TFhirComposite;
begin
  result := TFhirComposite(inherited Link);
end;

{ TFhirCompositeList }

procedure TFhirCompositeList.add(aResourceType: TFhirResourceType; name: String; components: array of String);
var
  ndx : TFhirComposite;
  i : integer;
begin
  ndx := TFhirComposite.Create;
  try
    ndx.ResourceType := aResourceType;
    ndx.name := name;
    i := 0;
    while (i < length(components)) do
    begin
      ndx.Components.Add(components[i], components[i+1]);
      inc(i, 2);
    end;
    inherited add(ndx.Link);
  finally
    ndx.free;
  end;

end;

function TFhirCompositeList.getByName(atype: TFhirResourceType; name: String): TFhirComposite;
var
  i : integer;
begin
  i := 0;
  result := nil;
  while (result = nil) and (i < Count) do
  begin
    if SameText(item[i].name, name) and (item[i].FResourceType = atype) then
      result := item[i];
    inc(i);
  end;
end;

function TFhirCompositeList.GetItemN(iIndex: integer): TFhirComposite;
begin
  result := TFhirComposite(ObjectByIndex[iIndex]
  );
end;

function TFhirCompositeList.ItemClass: TAdvObjectClass;
begin
  result := TFhirComposite;
end;

function TFhirCompositeList.Link: TFhirCompositeList;
begin
  result := TFhirCompositeList(inherited Link);
end;


initialization
  TFhirIndexManager.Create(nil).free;
end.


