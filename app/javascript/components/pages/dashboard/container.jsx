/* TODO Update the referencing comments after properly updating the files */
// Dashboard Component that import all the Graphs in it.

/* eslint-disable react/jsx-no-target-blank */
/* eslint-disable global-require */

import { useEffect } from "react";
import { useDispatch } from "react-redux";
import { Grid } from "@material-ui/core";

import { useI18n } from "../../i18n";
import PageContainer, { PageHeading, PageContent } from "../../page";
import { getPermissions } from "../../user/selectors";
import { getLoading, getErrors } from "../../index-table";
import { OfflineAlert } from "../../disable-offline";
import { usePermissions, ACTIONS, RESOURCES } from "../../permissions";
import { RECORD_PATH } from "../../../config";
import { useMemoizedSelector } from "../../../libs";

import {
  Approvals,
  CasesBySocialWorker,
  CasesToAssign,
  Flags,
  OverdueTasks,
  Overview,
  PerpetratorArmedForceGroupPartyNames,
  ProtectionConcern,
  ReportingLocation,
  SharedFromMyTeam,
  SharedWithMyTeam,
  ViolationsCategoryRegion,
  ViolationsCategoryVerificationStatus,
  WorkflowIndividualCases,
  WorkflowTeamCases,
  // 'Percentage of Children who received Child Protection Services'
  PercentageChildrenReceivedChildProtectionServices,
  // --------------------------------------------------------------
  // resolved_cases_by_gender_and_types_of_violence_stats
  // Closed Cases by Sex and Protection Concern
  RegResCasesGender,
  // --------------------------------------------------------------
  // cases_referral_to_agency_stats
  // Cases Referral (To Agency )
  CasesReferralToAgency,
  // --------------------------------------------------------------
  // alternative_care_placement_by_gender
  // Cases requiring Alternative Care Placement Services
  GraphFour,
  // --------------------------------------------------------------
  // month_wise_registered_and_resolved_cases_stats
  // Registered and Closed Cases by Month
  MonthlyRegResCases,
  // --------------------------------------------------------------
  // significant_harm_cases_registered_by_age_and_gender_stats
  // Significant Harm Cases by Protection Concern
  HarmCases,
  // --------------------------------------------------------------
  // registered_cases_by_protection_concern
  // Registered Cases by Protection Concern
  RegisteredCasesByProtectionConcern
  // --------------------------------------------------------------
} from "./components";
import NAMESPACE from "./namespace";
import { NAME } from "./constants";
import { fetchDashboards, fetchFlags } from "./action-creators";

const Dashboard = () => {
  const i18n = useI18n();
  const dispatch = useDispatch();
  const canFetchFlags = usePermissions(RESOURCES.dashboards, [ACTIONS.DASH_FLAGS]);

  useEffect(() => {
    dispatch(fetchDashboards());

    if (canFetchFlags) {
      dispatch(fetchFlags(RECORD_PATH.cases, true));
    }
  }, []);

  const userPermissions = useMemoizedSelector(state => getPermissions(state));
  const loading = useMemoizedSelector(state => getLoading(state, NAMESPACE));
  const errors = useMemoizedSelector(state => getErrors(state, NAMESPACE));
  const loadingFlags = useMemoizedSelector(state => getLoading(state, [NAMESPACE, "flags"]));
  const flagsErrors = useMemoizedSelector(state => getErrors(state, [NAMESPACE, "flags"]));

  const indicatorProps = {
    overlay: true,
    type: NAMESPACE,
    loading,
    errors
  };

  const flagsIndicators = {
    overlay: true,
    type: NAMESPACE,
    loading: loadingFlags,
    errors: flagsErrors
  };

  return (
    <PageContainer>
      <PageHeading title={i18n.t("navigation.home")} />
      <PageContent>
        <OfflineAlert text={i18n.t("messages.dashboard_offline")} />
        <Grid container spacing={3}>
          <Grid item xl={12} md={12} xs={12}>
            <CasesToAssign loadingIndicator={indicatorProps} />
            <Approvals loadingIndicator={indicatorProps} />
            <SharedFromMyTeam loadingIndicator={indicatorProps} />
            <SharedWithMyTeam loadingIndicator={indicatorProps} />
            <OverdueTasks loadingIndicator={indicatorProps} />
            <CasesBySocialWorker loadingIndicator={indicatorProps} />
            <WorkflowTeamCases loadingIndicator={indicatorProps} />
            <ReportingLocation loadingIndicator={indicatorProps} />
            <ProtectionConcern loadingIndicator={indicatorProps} />
            <ViolationsCategoryVerificationStatus loadingIndicator={indicatorProps} />
            <ViolationsCategoryRegion loadingIndicator={indicatorProps} />
            <PerpetratorArmedForceGroupPartyNames loadingIndicator={indicatorProps} />
          </Grid>

          <Grid item xl={12} md={12} xs={12}>
            <Overview loadingIndicator={indicatorProps} userPermissions={userPermissions} />
            <WorkflowIndividualCases loadingIndicator={indicatorProps} />
            {/* Percentage of Children who received Child Protection Services */}
            <PercentageChildrenReceivedChildProtectionServices />
            <RegResCasesGender /> {/* Closed Cases by Sex and Protection Concern */}
            <CasesReferralToAgency /> {/* Cases Referral (To Agency ) */}
            <GraphFour /> {/* Cases requiring Alternative Care Placement Services */}
            <MonthlyRegResCases /> {/* Registered and Closed Cases by Month */}
            <HarmCases /> {/* Significant Harm Cases by Protection Concern */}
            <RegisteredCasesByProtectionConcern /> {/* Registered Cases by Protection Concern */}
          </Grid>

          <Grid item xl={3} md={4} xs={12}>
            <Flags loadingIndicator={flagsIndicators} />
          </Grid>
        </Grid>
      </PageContent>
    </PageContainer>
  );
};

Dashboard.displayName = NAME;

export default Dashboard;
