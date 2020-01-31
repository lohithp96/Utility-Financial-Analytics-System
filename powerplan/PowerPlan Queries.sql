/* AFUDC by Work Order or Funding Project */

select distinct woc.company_id,woc.work_order_number,woc.description Project_Description, decode(woc.funding_wo_indicator, 1,'funding_project', 'work_order') WO_or_FP, 
bd.budget_number, bd.description Budget_description,
woc.in_service_Date,woa.eligible_for_afudc, a.description afudc_type, jt.external_job_task, jt.field1, co.description close_option
from work_order_control woc, work_order_account woa, company c, afudc_control a, job_task jt, closing_option co, budget bd
where woa.work_order_id=woc.work_order_id
and woc.budget_id = bd.budget_id
and a.afudc_type_id=woa.afudc_type_id
and woc.company_id=c.company_id
and jt.work_order_id (+)=woc.work_order_id
and woa.closing_option_id=co.closing_option_id


/* Unit Estimate Query by Funding Project */
select c.gl_company_no company, woc.work_order_number, woc.description Project_Description , decode(woc.funding_wo_indicator, 1,'funding_project', 'work_order') WO_or_FP,
bd.budget_number, bd.description Budget_description, status.description status,woc.in_service_date, woc.completion_date,we.job_task_id job_task,jt.field4 field4, we.revision, et.description expenditure_type, ua.description utility_account, ru.description retirement_unit, al.long_description asset_location, ect.description charge_type, quantity,amount
from work_order_control woc, wo_estimate we, utility_account ua, retirement_unit ru, asset_location al, estimate_charge_type ect, expenditure_type et, company c, job_task jt, work_order_status status, budget bd
where woc.company_id = c.company_id
and we.work_order_Id = woc.work_order_id
and woc.budget_id = bd.budget_id
and woc.wo_status_id = status.wo_status_id
and we.utility_account_id = ua.utility_account_id (+)
and we.retirement_unit_id = ru.retirement_unit_id (+)
and we.asset_location_id = al.asset_location_id (+)
and we.est_chg_type_id = ect.est_chg_type_id (+)
and we.expenditure_type_Id = et.expenditure_type_Id (+)
and we.job_task_id = jt.job_task_id (+)
order by 1,2,3,4,5
