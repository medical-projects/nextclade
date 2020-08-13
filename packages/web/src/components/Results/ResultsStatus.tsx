import React from 'react'

import { Progress } from 'reactstrap'
import { connect } from 'react-redux'
import styled from 'styled-components'

import type { State } from 'src/state/reducer'
import type { AlgorithmSequenceStatus } from 'src/state/algorithm/algorithm.state'
import { selectStatus } from 'src/state/algorithm/algorithm.selectors'

const ResultsStatusWrapper = styled.div`
  height: 32px;
  margin: 0;
`

export interface SequenceStatus {
  seqName: string
  status: AlgorithmSequenceStatus
}

export interface ResultsStatusProps {
  status: { percent: number; statusText: string; failureText?: string }
}

const mapStateToProps = (state: State) => ({
  status: selectStatus(state),
})

const mapDispatchToProps = {}

export const ResultsStatus = connect(mapStateToProps, mapDispatchToProps)(ResultsStatusDisconnected)

export function ResultsStatusDisconnected({ status }: ResultsStatusProps) {
  const { percent, statusText, failureText } = status

  let color = percent === 0 || percent === 100 ? 'transparent' : undefined
  if (failureText) {
    color = 'danger'
  }

  let text = <span>{statusText}</span>
  if (failureText) {
    text = (
      <>
        <span>{statusText}</span>
        <span>{'. '}</span>
        <span className="text-danger">{failureText}</span>
      </>
    )
  }

  return (
    <ResultsStatusWrapper>
      <div className="text-right">{text}</div>
      <Progress color={color} value={percent} />
    </ResultsStatusWrapper>
  )
}
