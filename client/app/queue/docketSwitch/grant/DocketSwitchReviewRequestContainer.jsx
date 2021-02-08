import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { DocketSwitchReviewRequestForm } from './DocketSwitchReviewRequestForm';
import { useHistory, useParams } from 'react-router';
import { appealWithDetailSelector } from '../../selectors';
import { updateDocketSwitch, stepForward } from '../docketSwitchSlice';

export const DocketSwitchReviewRequestContainer = () => {
  const dispatch = useDispatch();
  const { appealId, taskId } = useParams();
  const { goBack, push } = useHistory();

  const appeal = useSelector((state) =>
    appealWithDetailSelector(state, { appealId })
  );

  // Reminder to add code to clear docketSwitch redux store when we go back.
  const handleCancel = () => goBack();

  const handleSubmit = async (formData) => {

    try {
      await dispatch(updateDocketSwitch({ formData }));
      dispatch(stepForward());
      push(`/queue/appeals/${appealId}/tasks/${taskId}/docket_switch/checkout/grant/tasks`);
    } catch (error) {
      // Perhaps show an alert that indicates error, advise trying again...?
    }
  };

  return (
    <>
      <DocketSwitchReviewRequestForm
        onCancel={handleCancel}
        onSubmit={handleSubmit}
        appellantName={appeal.appellantFullName}
        docketFrom={appeal.docketName}
        issues={appeal.issues}
      />
    </>
  );
};
