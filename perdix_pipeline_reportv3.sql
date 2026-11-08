-- CREATE DEFINER=`digitallos_user`@`%` PROCEDURE `digital_LOS`.`PerdixPipelineReportV2`(
-- IN iZone_name VARCHAR(50),
--  IN istate VARCHAR(50),
--  IN iDivision VARCHAR(50),
--  IN iRegion_name VARCHAR(50),
--  IN iBranch_name VARCHAR(50),
--  IN iSpoke_name VARCHAR(50),
--  IN icreatedAt_from DATE,
--  IN icreatedAt_to DATE,
--  IN iLastUpdatedTime_from DATE,
--  IN iLastUpdatedTime_to DATE
--  -- ,OUT concattext VARCHAR(10000)
-- )
-- BEGIN

--1
SET @PerdixScreeningFirst ='(select
  CASE LA.current_stage
		
    WHEN ''ScreeningReview'' THEN ''Screening Review''
   
    WHEN ''ApplicationReview'' THEN ''Application Review''
    ELSE LA.current_stage end as currentStage
  ,LA.current_stage as ''currentTask'', ''Screening'' as ''Group'',''Perdix'' as ''Source'',COUNT(*) as "Number_of_Accounts",
       CASE LA.current_stage
		WHEN ''Screening'' THEN 1
    WHEN ''ScreeningReview'' THEN 2
    WHEN ''Application'' THEN 3
    WHEN ''ApplicationReview'' THEN 4
    ELSE 99
	end Sequence ,
      SUM(LA.loan_amount) as "Proposed_Loan_Amount",''0%'' as "Probable_Achieving_Percentage",
      ROUND((SUM(LA.loan_amount) * 0) / 100, 0) as "Probable_Achieving_Amount"
      from perdix_online.dw_loan_accounts LA
      LEFT JOIN perdix_online.dw_loan_centre LC
      on LA.loan_id = LC.loan_id
      left join mdm_db.ZoneHierarchy ZH
      on LC.centre_id =  ZH.Spoke_ID where LA.current_stage in(''Screening'',''ScreeningReview'',''Application'',''ApplicationReview'') 
      and LA.scd_end is null ';
SET @PerdixScreeningLast='group by  LA.current_stage)';
-------------------------------------------------------
SELECT 
CASE 	
        WHEN ( LA.current_stage = 'ScreeningReview') THEN 'Screening Review'
        WHEN ( LA.current_stage = 'ApplicationReview') THEN 'Application Review'
        ELSE  LA.current_stage 
    END AS currentStage,  LA.current_stage as currentTask, 'Screening' as "Group",'Perdix' as "Source",COUNT(*) as Number_of_Accounts,
CASE 
        WHEN ( LA.current_stage = 'Screening') THEN 1
        WHEN ( LA.current_stage = 'ScreeningReview') THEN 2
        WHEN ( LA.current_stage = 'Application') THEN 3
        WHEN ( LA.current_stage = 'ApplicationReview') THEN 4
    ELSE 99
    END SEQUENCE,
    SUM(LA.loan_amount) as "Proposed_Loan_Amount",'0%' as "Probable_Achieving_Percentage",
    ROUND((SUM(LA.loan_amount) * 0) / 100, 0) as "Probable_Achieving_Amount"
    FROM DATA_PLATFORM_DB.AURORA.DW_LOAN_ACCOUNTS LA
        
        LEFT JOIN DATA_PLATFORM_DB.AURORA.DW_LOAN_CENTRE  LC
        ON LA.loan_id = LC.loan_id
        LEFT JOIN DATA_PLATFORM_DB.AURORA.ZONEHIERARCHY ZH
        ON LC.centre_id =  ZH.Spoke_ID 
        WHERE  LA.current_stage IN ('Screening','ScreeningReview','Application','ApplicationReview') 
        and LA.scd_end IS NULL
        group by LA.current_stage

union all
---2
SET @PerdixCentralRiskQueueFirst ='(select 
     CASE LA.current_stage
		WHEN ''FieldAppraisal'' THEN ''Field Appraisal''
    WHEN ''FieldAppraisalReview'' THEN ''Field Appraisal Review''
    WHEN ''CentralRiskReview'' THEN ''Central Risk Review''
    WHEN ''ZonalRiskReview'' THEN ''Zonal Risk Review''
    WHEN ''CreditCommitteeReview'' THEN ''Credit Committee Review''
    WHEN ''SVPCreditRiskReview'' THEN ''SVP Credit Risk Review''
    WHEN ''CreditCommitteeReview'' THEN ''Credit Committee Review''
    
    ELSE LA.current_stage
	end currentStage
    ,LA.current_stage as ''currentTask'', ''Central Risk Queue'' as ''Group'',''Perdix'' as ''Source'',COUNT(*) as "Number_of_Accounts",
       CASE LA.current_stage
		WHEN ''FieldAppraisal'' THEN 1
    WHEN ''FieldAppraisalReview'' THEN 1
    WHEN ''CentralRiskReview'' THEN 2
    WHEN ''ZonalRiskReview'' THEN 3
    WHEN ''CreditCommitteeReview'' THEN 4
    WHEN ''SVPCreditRiskReview'' THEN 5
    WHEN ''CreditCommitteeReview'' THEN 6
  
    ELSE 99
	end Sequence ,
      SUM(LA.loan_amount) as "Proposed_Loan_Amount",''75%'' as "Probable_Achieving_Percentage",
      ROUND((SUM(LA.loan_amount) * 75) / 100, 0) as "Probable_Achieving_Amount"
      from perdix_online.dw_loan_accounts LA
      LEFT JOIN perdix_online.dw_loan_centre LC
      on LA.loan_id = LC.loan_id
      left join mdm_db.ZoneHierarchy ZH
      on LC.centre_id =  ZH.Spoke_ID where LA.current_stage in
      (''FieldAppraisal'',''FieldAppraisalReview'',''CentralRiskReview'',''CreditCommitteeReview'',''ZonalRiskReview'',''SVPCreditRiskReview'',''CreditCommitteeReview'') 
      and LA.scd_end is null ';
SET @PerdixCentralRiskQueueLast='group by LA.current_stage )';
---------------------------------------------------------------
SELECT 
    CASE LA.current_stage
            WHEN 'FieldAppraisal' THEN 'Field Appraisal'
            WHEN 'FieldAppraisalReview' THEN 'Field Appraisal Review'
            WHEN 'CentralRiskReview' THEN 'Central Risk Review'
            WHEN 'ZonalRiskReview' THEN 'Zonal Risk Review'
            WHEN 'CreditCommitteeReview' THEN 'Credit Committee Review'
            WHEN 'SVPCreditRiskReview' THEN 'SVP Credit Risk Review'
            WHEN 'CreditCommitteeReview' THEN 'Credit Committee Review'
    
        ELSE LA.current_stage
	    END stagename
    ,LA.current_stage as currentTask, 'Central Risk Queue' as "Group",'Perdix' as "Source",COUNT(*) as "Number_of_Accounts",
    CASE LA.current_stage
        WHEN 'FieldAppraisal' THEN 1
        WHEN 'FieldAppraisalReview' THEN 1
        WHEN 'CentralRiskReview' THEN 2
        WHEN 'ZonalRiskReview' THEN 3
        WHEN 'CreditCommitteeReview'THEN 4
        WHEN 'SVPCreditRiskReview' THEN 5
        WHEN 'CreditCommitteeReview' THEN 6 
    ELSE 99
	END SEQUENCE ,
        SUM(LA.loan_amount) as "Proposed_Loan_Amount",'75%' as "Probable_Achieving_Percentage",
        ROUND((SUM(LA.loan_amount) * 75) / 100, 0) as "Probable_Achieving_Amount"
    FROM DATA_PLATFORM_DB.AURORA.DW_LOAN_ACCOUNTS LA
        LEFT JOIN DATA_PLATFORM_DB.AURORA.DW_LOAN_CENTRE  LC
        ON LA.loan_id = LC.loan_id
        LEFT JOIN DATA_PLATFORM_DB.AURORA.ZONEHIERARCHY ZH
        ON LC.centre_id =  ZH.Spoke_ID WHERE  LA.current_stage IN 
        ('FieldAppraisal','FieldAppraisalReview','CentralRiskReview','CreditCommitteeReview','ZonalRiskReview','SVPCreditRiskReview','CreditCommitteeReview') 
        
        and LA.scd_end IS NULL
    GROUP BY LA.current_stage
union all

--3
SET @PerdixApprovalFirst ='(select 
CASE LA.current_stage
		WHEN ''LoanInitiation'' THEN ''Loan Initiation''
    WHEN ''LoanBooking'' THEN ''Loan Booking''
    WHEN ''PendingForPartner'' THEN ''Pending For Partner''
    WHEN ''LinkedAccountVerification'' THEN ''Linked Account Verification''
    WHEN ''AutoDocumentExecution'' THEN ''Auto Document Execution''
    WHEN ''FailedAutoDocumentExecution'' THEN ''Auto Document Execution Failed Queue''
    WHEN ''AutoDocumentVerification'' THEN ''Auto Document Verification''
    WHEN ''FailedAutoDocumentVerification'' THEN ''Auto Document Verification Failed Queue''
     WHEN ''DocumentVerification'' THEN ''Document Verification''
      WHEN ''TechnicalFailure'' THEN ''Technical Failure''
    ELSE LA.current_stage
	
	end currentStage
,LA.current_stage as ''currentTask'', ''Approval'' as ''Group'',''Perdix'' as ''Source'',COUNT(*) as "Number_of_Accounts",
CASE LA.current_stage
		WHEN ''LoanInitiation'' THEN 1
    WHEN ''LoanBooking'' THEN 2
    WHEN ''PendingForPartner'' THEN 3
    WHEN ''Sanction''  THEN 4
    WHEN ''LinkedAccountVerification'' THEN 5
    WHEN ''AutoDocumentExecution'' THEN 6
    WHEN ''FailedAutoDocumentExecution'' THEN 7
    WHEN ''AutoDocumentVerification'' THEN 8
    WHEN ''FailedAutoDocumentVerification'' THEN 9
     WHEN ''DocumentVerification'' THEN 10
      WHEN ''TechnicalFailure'' THEN 11
    ELSE 99
	end Sequence ,
      SUM(LA.loan_amount) as "Proposed_Loan_Amount",''90%'' as "Probable_Achieving_Percentage",
      ROUND((SUM(LA.loan_amount) * 90) / 100, 0) as "Probable_Achieving_Amount"
      from perdix_online.dw_loan_accounts LA
      LEFT JOIN perdix_online.dw_loan_centre LC
      on LA.loan_id = LC.loan_id
      left join mdm_db.ZoneHierarchy ZH
      on LC.centre_id =  ZH.Spoke_ID where LA.current_stage in
      (''LoanInitiation'',''LoanBooking'',''Sanction'',''LinkedAccountVerification'',''PendingForPartner'',''AutoDocumentExecution'',''FailedAutoDocumentExecution'',''FailedAutoDocumentVerification'',''AutoDocumentVerification'',''DocumentVerification'',''TechnicalFailure'') 
      and LA.scd_end is null ';

SET @PerdixApprovalLast='group by LA.current_stage)';
-------------------------------------------------------
SELECT 
CASE LA.current_stage
	WHEN 'LoanInitiation' THEN 'Loan Initiation'
    WHEN 'LoanBooking' THEN 'Loan Booking'
    WHEN 'PendingForPartner' THEN 'Pending For Partner'
    WHEN 'LinkedAccountVerification' THEN 'Linked Account Verification'
    WHEN 'AutoDocumentExecution' THEN 'Auto Document Execution'
    WHEN 'FailedAutoDocumentExecution' THEN 'Auto Document Execution Failed Queue'
    WHEN 'AutoDocumentVerification' THEN 'Auto Document Verification'
    WHEN 'FailedAutoDocumentVerification' THEN 'Auto Document Verification Failed Queue'
    WHEN 'DocumentVerification' THEN 'Document Verification'
    WHEN 'TechnicalFailure' THEN 'Technical Failure'
    ELSE LA.current_stage
	END currentStage
,LA.current_stage as "currentTask", 'Approval' as "Group",'Perdix' as "Source",COUNT(*) as "Number_of_Accounts",
CASE LA.current_stage
	WHEN 'LoanInitiation' THEN 1
    WHEN 'LoanBooking' THEN 2
    WHEN 'PendingForPartner' THEN 3
    WHEN 'Sanction' THEN 4
    WHEN 'LinkedAccountVerification' THEN 5
    WHEN 'AutoDocumentExecution' THEN 6
    WHEN 'FailedAutoDocumentExecution' THEN 7
    WHEN 'AutoDocumentVerification' THEN 8
    WHEN 'FailedAutoDocumentVerification' THEN 9
    WHEN 'DocumentVerification' THEN 10
    WHEN 'TechnicalFailure'THEN 11
    ELSE 99
	END SEQUENCE ,
        SUM(LA.loan_amount) as "Proposed_Loan_Amount",'90%' as "Probable_Achieving_Percentage",
        ROUND((SUM(LA.loan_amount) * 90) / 100, 0) as "Probable_Achieving_Amount"
    FROM DATA_PLATFORM_DB.AURORA.DW_LOAN_ACCOUNTS LA
        LEFT JOIN DATA_PLATFORM_DB.AURORA.DW_LOAN_CENTRE  LC
        ON LA.loan_id = LC.loan_id
        LEFT JOIN DATA_PLATFORM_DB.AURORA.ZONEHIERARCHY ZH
        ON LC.centre_id =  ZH.Spoke_ID WHERE  LA.current_stage IN 
        ('LoanInitiation','LoanBooking','Sanction','LinkedAccountVerification','PendingForPartner','AutoDocumentExecution','FailedAutoDocumentExecution','FailedAutoDocumentVerification','AutoDocumentVerification','DocumentVerification','TechnicalFailure') 

        
        and LA.scd_end IS NULL GROUP BY LA.current_stage

union all

--4
SET @PerdixRejectedFirst ='(select LA.current_stage as ''currentStage'',LA.current_stage as ''currentTask'', ''Rejected'' as ''Group'',''Perdix'' as ''Source'',COUNT(*) as "Number_of_Accounts",
CASE LA.current_stage
	  	WHEN ''Rejected'' THEN 1
    
       ELSE 1
	    end Sequence ,
      SUM(LA.loan_amount) as "Proposed_Loan_Amount",''0%'' as "Probable_Achieving_Percentage",
      ROUND((SUM(LA.loan_amount) * 0) / 100, 0) as "Probable_Achieving_Amount"
      from perdix_online.dw_loan_accounts LA
      LEFT JOIN perdix_online.dw_loan_centre LC
      on LA.loan_id = LC.loan_id
      left join mdm_db.ZoneHierarchy ZH
      on LC.centre_id =  ZH.Spoke_ID where LA.current_stage in
      (''Rejected'') 
      and LA.scd_end is null ';
SET @PerdixRejectedLast='group by LA.current_stage)';
--------------------------------------------------------
SELECT LA.current_stage as currentStage,LA.current_stage as currentTask, 'Rejected' as "Group",'Perdix' as "Source",COUNT(*) as "Number_of_Accounts",
    CASE LA.current_stage
	WHEN 'Rejected' THEN 1
    ELSE 1
	END SEQUENCE ,
      SUM(LA.loan_amount) as "Proposed_Loan_Amount",'0%' as "Probable_Achieving_Percentage",
      ROUND((SUM(LA.loan_amount) * 0) / 100, 0) as "Probable_Achieving_Amount"
      FROM DATA_PLATFORM_DB.AURORA.DW_LOAN_ACCOUNTS LA
      LEFT JOIN DATA_PLATFORM_DB.AURORA.DW_LOAN_CENTRE  LC
      ON LA.loan_id = LC.loan_id
      LEFT JOIN DATA_PLATFORM_DB.AURORA.ZONEHIERARCHY ZH
      ON LC.centre_id =  ZH.Spoke_ID WHERE  LA.current_stage IN 
      ('Rejected') 

   
      and LA.scd_end IS NULL
      GROUP BY LA.current_stage

union all

--5
SET @PerdixDisbursedFirst='(select ''Disbursed'' as currentStage ,''Disbursed'' as currentTask , ''Disbursed'' as ''Group'',''Perdix'' as ''Source'',COUNT(*) as ''Number_of_Accounts'',
CASE LEDS.current_stage
		WHEN ''Completed'' THEN 1
    WHEN ''DisbursementConfirmation'' THEN 1 else 1 end as Sequence,
sum(disbursement_amount) as ''Proposed_Loan_Amount'',''100%'' as ''Probable_Achieving_Percentage'' ,
ROUND((SUM(disbursement_amount) * 100) / 100, 0) as ''Probable_Achieving_Amount''
from perdix_online.dw_loan_account_disbursement_schedule LEDS inner join  
 perdix_online.dw_loan_accounts  LA on LEDS.loan_id=LA.loan_id
LEFT JOIN perdix_online.dw_loan_centre LC
      on LA.loan_id = LC.loan_id
      left join mdm_db.ZoneHierarchy ZH
      on LC.centre_id =  ZH.Spoke_ID
Where LA.original_account_number is null and LA.scd_end is null and LC.scd_end is null and LEDS.scd_end is null and 
LEDS.current_stage in (
''Completed'',''DisbursementConfirmation'')  ';
-----------------------------------------------------
SELECT 'Disbursed' as currentStage ,'Disbursed' as currentTask , 'Disbursed' as "Group",'Perdix' as "Source",COUNT(*) as "Number_of_Accounts",
CASE LA.current_stage
	WHEN 'Completed' THEN 1
    WHEN 'DisbursementConfirmation' THEN 1 else 1 END AS Sequence,
    sum(disbursement_amount) as "Proposed_Loan_Amount",'100%' as "Probable_Achieving_Percentage" ,
    ROUND((SUM(disbursement_amount) * 100) / 100, 0) as "Probable_Achieving_Amount"
    
    FROM AURORA.DW_LOAN_ACCOUNT_DISBURSEMENT_SCHEDULE LEDS INNER JOIN 
    DATA_PLATFORM_DB.AURORA.DW_LOAN_ACCOUNTS  LA ON LEDS.loan_id=LA.loan_id
    LEFT JOIN DATA_PLATFORM_DB.AURORA.DW_LOAN_CENTRE  LC
    ON LA.loan_id = LC.loan_id
    LEFT JOIN DATA_PLATFORM_DB.AURORA.ZONEHIERARCHY ZH
    ON LC.centre_id =  ZH.Spoke_ID
WHERE  LA.original_account_number IS NULL and LA.scd_end IS NULL and LC.scd_end IS NULL and LEDS.scd_end IS NULL and 
LA.current_stage IN  (
'Completed','DisbursementConfirmation')
 and LA.scd_end IS NULL
        group by LA.current_stage


















------------------------------------------------------------
SET @PerdixConditionText = ' ';
SET @DisbursedConditionText = ' ';
if(ifnull(iSpoke_name,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(iBranch_name,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and ZH.Branch_name = ''',iBranch_name,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(iRegion_name,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Region_name = ''', iRegion_name,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(iDivision,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and ZH.Division = ''',iDivision,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(istate,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and ZH.state = ''',istate,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(iZone_name,'0') != '0') then
BEGIN

SET @PerdixConditionText = concat(@PerdixConditionText,' and ZH.Zone_name = ''', iZone_name,'''');
SET @PerdixConditionText = concat(@PerdixConditionText,' and  ZH.Spoke_name = ''',iSpoke_name,'''');
end;
end if;

if(ifnull(icreatedAt_from,'0') != '0') then
BEGIN

-- SET @PerdixConditionText = concat(@PerdixConditionText,' and ( date(LA.created_at) between ''', icreatedAt_from,'''  and  ''',icreatedAt_to,''')');
SET @PerdixConditionText = concat(@PerdixConditionText,' and ( date(LA.last_edited_at) between ''', icreatedAt_from,'''  and  ''',icreatedAt_to,''')');
SET @DisbursedConditionText = concat(@DisbursedConditionText,' and ( date(LEDS.scheduled_disbursement_date) between ''', icreatedAt_from,'''  and  ''',icreatedAt_to,'''))');
end;
end if;









SET @SQLPerdixQuery = concat(@PerdixScreeningFirst,@PerdixConditionText,@PerdixScreeningLast,
' UNION ALL ',@PerdixCentralRiskQueueFirst,@PerdixConditionText,@PerdixCentralRiskQueueLast,
' UNION ALL ',@PerdixApprovalFirst,@PerdixConditionText,@PerdixApprovalLast,
' UNION ALL ',@PerdixRejectedFirst,@PerdixConditionText,@PerdixRejectedLast ,
' UNION ALL ', @PerdixDisbursedFirst,@DisbursedConditionText
);

--  SELECT @SQLPerdixQuery into concattext;
  PREPARE stmt FROM @SQLPerdixQuery;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
-- END
