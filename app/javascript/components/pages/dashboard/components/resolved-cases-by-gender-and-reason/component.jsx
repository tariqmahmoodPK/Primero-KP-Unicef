// 'Closed Cases by Sex and Reason'

/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */

// Hook used for handling side effects in functional components.
// Used for Fetching data when the component is mounted.
import { useEffect } from "react";
// This is used for managing application state in a Redux store.
import { useDispatch } from "react-redux";
// Import styles from a Material UI library.
// Utility for defining CSS styles in a React component.
import makeStyles from "@material-ui/core/styles/makeStyles";
import { Grid } from "@material-ui/core";

import { BarChart } from "../../../../charts";
// Import functions for fetching data.
import { fetchResolvedCasesByGenderAndReason } from "../../action-creators";
// Import functions for selecting data.
import { getResolvedCasesByGenderAndReason } from "../../selectors";
// Import a custom library function.
import { useMemoizedSelector } from "../../../../../libs";

// Import styles for this component.
import styles from "./styles.css";

// Create a useStyles function to define and apply styles to ensure consistent styling to the component.
const useStyles = makeStyles(styles);

const Component = () => {
  // Contains CSS classes generated by makeStyles, which can be used to style elements in the component.
  const css = useStyles();

  // Get access to Redux's dispatch function to trigger actions.
  const dispatch = useDispatch();
  // Use the useMemoizedSelector function to get data from the Redux store.
  const data = useMemoizedSelector(state => getResolvedCasesByGenderAndReason(state));
  // Extract statistics from the data if it exists, otherwise set it to null.
  const stats = data.getIn(["data", "stats"]) ? data.getIn(["data", "stats"]).toJS() : null;

  // Use the useEffect hook to perform an action when the component is mounted.
  useEffect(() => {
    // Dispatch an action to fetch ResolvedCasesByGenderAndReason
    dispatch(fetchResolvedCasesByGenderAndReason());
  }, []);

  let graphData;
  const chartOptions = {
    scales: {
      xAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Closing Reason",
            fontColor: "red"
          }
        }
      ],
      yAxes: [
        {
          scaleLabel: {
            display: true,
            labelString: "Number of Cases",
            fontColor: "green"
          }
        }
      ]
    }
  };

  if (stats) {
    const labels = [];
    const cases = [];
    const male = [];
    const female = [];
    const transgender = [];

    for (const key in stats) {
      labels.push(key);
    }

    for (const key in stats) {
      cases.push(stats[key].cases);
      male.push(stats[key].male);
      female.push(stats[key].female);
      transgender.push(stats[key].transgender);
    }
    graphData = {
      labels,
      datasets: [
        {
          label: "Male",
          data: male,
          backgroundColor: "rgba(54, 162, 235)",
          stack: "Stack 0"
        },
        {
          label: "Female",
          data: female,
          backgroundColor: "rgb(255, 99, 132)",
          stack: "Stack 0"
        },
        {
          label: "Transgender",
          data: transgender,
          backgroundColor: "rgba(255, 159, 64)",
          stack: "Stack 0"
        }
      ]
    };
  }

  // Render the following JSX (JavaScript XML) content.
  return (
    <>
      {graphData && (
        <Grid item xl={6} md={6} xs={12}>
          {/* Create a container for displaying statistics */}
          <div className={css.container}>
            {/* Display a heading */}
            <h2>Closed Cases by Sex and Reason</h2>
            <div className={css.card} flat>
              <BarChart options={chartOptions} data={graphData} showDetails />
            </div>
          </div>
        </Grid>
      )}
    </>
  );
};

// Set a display name for the Component
Component.displayName = `ResolvedCasesByGenderAndReason`;

// Export the Component so it can be used in other parts of the application.
export default Component;
